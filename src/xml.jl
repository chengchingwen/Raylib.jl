# simple & dirty xml parser only for generate bindings

function parse_data(pairs)
    return NamedTuple(
        Pair(Symbol(m.captures[1]), m.captures[2]) for m in eachmatch(r"([^ ]+)=\"([^\"]*)\"", pairs)
    )
end

parse(f::AbstractString) = open(parse, f)
function parse(io::IO)
    stack = Int[]
    char_stream = Char[]
    records = Dict{Symbol, Any}[Dict()]
    sizehint!(stack, 20)
    sizehint!(char_stream, 200)

    idx = 0
    push_c = false
    while !eof(io)
        idx += 1
        c = read(io, Char)
        push!(char_stream, c)

        if c == '"' # avoid stacking </> in string
            char_stream[last(stack)] == '"' ? pop!(stack) : push!(stack, idx)
        elseif c == '<' # mark start position
            push_c = true
            push!(stack, idx)
        elseif c == '>'
            push_c = false
            pidx = pop!(stack)
            content = String(@view(char_stream[pidx:idx]))
            idx = pidx-1 # reset idx
            resize!(char_stream, idx) # remove content from stream

            m = match(r"</([^ ]+)>", content)
            if !isnothing(m)
                label = m.captures[]
                rec = pop!(records)
                if isempty(records)
                    push!(rec)
                end
                continue
            end

            m = match(r"<([^ ]+) (.+) />", content)
            if !isnothing(m)
                label, pairs = m.captures
                data = parse_data(pairs)
                push!(get!(last(records), Symbol(label), typeof(data)[]), data)
                continue
            end

            m = match(r"<\?.*\?>", content)
            if !isnothing(m)
                @debug "ignore xml header"
                continue
            end

            m = match(r"<([^ ]+)( .+)?>", content)
            if !isnothing(m)
                label, pairs = m.captures
                sym = Symbol(label)
                rr = last(records)

                record = Dict{Symbol, Any}()
                if haskey(rr, sym)
                    rlist = rr[sym]
                    if rlist isa Vector
                        push!(rlist, record)
                    else
                        rr[sym] = [rlist, record]
                    end
                else
                    rr[sym] = record
                end
                push!(records, record)

                if !isnothing(pairs)
                    record[:attr] = parse_data(pairs)
                end

                continue
            end

            @debug "cannnot parse content: $content"
        else
            if !push_c
                pop!(char_stream)
                idx -= 1
            end
        end
    end
    @assert all(isempty, (stack, char_stream))
    return records[]
end
