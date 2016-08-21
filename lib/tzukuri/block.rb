require 'lz4-ruby'

module Tzukuri
    class Block
        LITTLE_ENDIAN_32BIT_INT = 'l<'
        INT_LENGTH = 4
        HEADER = 'TZUD'

        attr_reader :entries

        def initialize(io)
            @entries = []
            
            # ensure we're starting on a block boundary
            header = io.read(HEADER.length)
            raise 'invalid block boundary' unless header == HEADER

            # parse the 4 byte compressed data length int
            compressed_length_bytes = io.read(INT_LENGTH)
            begin
                compressed_length = compressed_length_bytes.unpack(LITTLE_ENDIAN_32BIT_INT)[0]
                raise 'invalid compressed length' if compressed_length.nil? # when compressed_length_bytes.length is < INT_LENGTH
            rescue NoMethodError # when compressed_length_bytes is nil
                raise 'invalid compressed length'
            end

            # parse the 4 byte uncompressed data length int
            data_length_bytes = io.read(INT_LENGTH)
            begin
                data_length = data_length_bytes.unpack(LITTLE_ENDIAN_32BIT_INT)[0]
                raise 'invalid data length' if data_length.nil?
            rescue NoMethodError
                raise 'invalid data length'
            end
            
            # capture the compressed block data
            compressed = io.read(compressed_length)
            raise 'truncated compressed data' unless compressed.length == compressed_length

            # decompress and sanity check
            data, length = LZ4::Raw.decompress(compressed, data_length)
            raise 'truncated raw data' unless data.length == data_length

            # parse each entry
            data_io = StringIO.new(data)
            prev_ts = 0
            until data_io.eof?
                entry = Tzukuri::Entry.new(data_io, prev_ts)
                @entries << entry
                prev_ts = entry.ts
            end
        end
    end
end
