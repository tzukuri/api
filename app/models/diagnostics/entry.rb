class Entry
    attr_accessor :ts, :type, :value

    def initialize(io, prev_ts)
        # we don't need to check io.eof? here as the Block.init loop won't
        # continue and init us if eof is reached. when varint calls io.read(1)
        # it will succeed at least once

        # all timestamps are multiplied by 1000 to preserve fractional part
        @ts = (varint(io)/1000.0) + prev_ts

        @type = io.read(1)
        if @type.nil?
            @type = -1
            return
        else
            @type = @type.ord
        end

        raise 'truncated entry' if io.eof?
        value_length = varint(io)
        @value = io.read(value_length)
        raise 'truncated value data' unless @value.length == value_length
    end

    def varint(io)
        number = 0
        n = 0

        while true
            byte = io.read(1)
            return number if byte.nil?
            byte = byte.ord

            # if msb is set, continue reading
            more = byte >> 7

            # number is little endian encoded, so the first byte
            # encodes bits 0-6, the second byte 7-13 and so on.
            # we need to remove the msb, and shift the byte so it
            # represents the correct bits in the number
            byte &= 0x7F # AND mask remove the msb
            incr = byte << (7 * n)
            number += incr

            n += 1

            return number unless more == 1
        end
    end
end
