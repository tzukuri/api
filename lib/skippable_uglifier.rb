class SkippableUglifier < Uglifier
    def run_uglifyjs(input, generate_map)
        if input =~ /^\/\/= skip_uglifier/
            input.gsub(/\/\/= ?skip_uglifier(\n)*;(\n)*\z/, "")
        else
            super
        end
    end
end
