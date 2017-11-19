
function withTarget(action::Function, htmlpath::String)
    tg = Target("file://$htmlpath")
    action(tg)
    close(tg)
end

function getPlotNodeId(tg::Target)
    send(tg, "Page.enable")
    send(tg, "DOM.enable")

    send(tg, "DOM.getDocument")

    # search with xpath '.marks'
    resp = send(tg, "DOM.performSearch", query=".marks")
    resp["result"]["resultCount"] == 0 && error("plot not found")
    resp["result"]["resultCount"] > 1 && error("plot not located")
    sid = resp["result"]["searchId"]

    resp = send(tg, "DOM.getSearchResults", searchId=sid, fromIndex=0, toIndex=1)
    length(resp["result"]["nodeIds"]) != 1 && error("inconsistent number of plot node Ids")
    pid = resp["result"]["nodeIds"][1]
    (pid == 0) && error("node not found")

    pid
end

function getBoxModel(tg::Target, nodeId::Int)
    resp = send(tg, "DOM.getBoxModel", nodeId=nodeId)
    quad = resp["result"]["model"]["content"]
    Dict(:x => quad[1], :y => quad[2],
         :width  => quad[3] - quad[1] + 1,
         :height => quad[6] - quad[2] + 1,
         :scale => 1.0)
end

@compat function Base.show(io::IO, m::MIME"image/svg+xml", v::VLSpec{:plot})
    write(io, """<?xml version="1.0" encoding="utf-8"?>""")
    write(io, """<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">""")

    tmppath = writehtml_full(JSON.json(v.params))
    withTarget(tmppath) do tg
        nid = getPlotNodeId(tg)
        resp = send(tg, "DOM.getOuterHTML", nodeId=nid)
        write(io, resp["result"]["outerHTML"])
    end
    nothing
end

@compat function Base.show(io::IO, m::MIME"application/pdf", v::VLSpec{:plot})
    tmppath = writehtml_full(JSON.json(v.params))

    withTarget(tmppath) do tg
        send(tg, "Page.printToPDF") do resp
            write(io, base64decode(resp["result"]["data"]))
        end
    end
    nothing
end

@compat function Base.show(io::IO, m::MIME"image/png", v::VLSpec{:plot})
    tmppath = writehtml_full(JSON.json(v.params))

    withTarget(tmppath) do tg
        # find coordinates of VegaLite plot
        vp = getBoxModel(tg, getPlotNodeId(tg))
        println(vp)

        send(tg, "Page.captureScreenshot", format="png", clip=vp) do resp
            write(io, base64decode(resp["result"]["data"]))
        end
    end
    nothing
end

@compat function Base.show(io::IO, m::MIME"image/jpeg", v::VLSpec{:plot})
    tmppath = writehtml_full(JSON.json(v.params))

    withTarget(tmppath) do tg
        # find coordinates of VegaLite plot
        vp = getBoxModel(tg, getPlotNodeId(tg))

        send(tg, "Page.captureScreenshot", format="jpg", clip=vp) do resp
            write(io, base64decode(resp["result"]["data"]))
        end
    end
    nothing
end
