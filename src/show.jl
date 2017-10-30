
function withTarget(action::Function, htmlpath::String)
    tg = Target("file:///$htmlpath")
    action(tg)
    close(tg)
end

function getPlotNodeId(tg::Target)
    send(tg, "DOM.getDocument")

    # search with xpath 'svg.marks'
    resp = send(tg, "DOM.performSearch", query="svg.marks")
    resp["result"]["resultCount"] == 0 && error("plot not found")
    resp["result"]["resultCount"] > 1 && error("plot not located")
    sid = resp["result"]["searchId"]

    resp = send(tg, "DOM.getSearchResults", searchId=sid, fromIndex=0, toIndex=1)
    length(resp["result"]["nodeIds"]) != 1 && error("inconsistent number of plot node Ids")
    pid = resp["result"]["nodeIds"][1]
    (pid == 0) && error("node not found")

    pid
end

function getBoxModel(tg::Target, nodeId::Int64)
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
    svgstyle = "xmlns=\"http://www.w3.org/2000/svg\""

    tmppath = writehtml_full(JSON.json(v.params))
    withTarget(tmppath) do tg
        nid = getPlotNodeId(tg)
        resp = send(tg, "DOM.getOuterHTML", nodeId=nid)
        rawstr = resp["result"]["outerHTML"]
        write(io, rawstr[1:5] * svgstyle * rawstr[5:end] )
    end
    nothing
end

@compat function Base.show(io::IO, m::MIME"application/pdf", v::VLSpec{:plot})
    tmppath = writehtml_full(JSON.json(v.params))

    withTarget(tmppath) do tg
        send(tg, "DOM.getDocument") # forces evaluation ?
        resp = send(tg, "Page.printToPDF")
        write(io, base64decode(resp["result"]["data"]))
    end
    nothing
end

@compat function Base.show(io::IO, m::MIME"image/png", v::VLSpec{:plot})
    tmppath = writehtml_full(JSON.json(v.params))

    withTarget(tmppath) do tg
        vp = getBoxModel(tg, getPlotNodeId(tg)) # find coordinates of VegaLite plot

        resp = send(tg, "Page.captureScreenshot", format="png", clip=vp)
        write(io, base64decode(resp["result"]["data"]))
    end
    nothing
end

@compat function Base.show(io::IO, m::MIME"image/jpeg", v::VLSpec{:plot})
    tmppath = writehtml_full(JSON.json(v.params))

    withTarget(tmppath) do tg
        vp = getBoxModel(tg, getPlotNodeId(tg)) # find coordinates of VegaLite plot

        resp = send(tg, "Page.captureScreenshot", format="jpeg", clip=vp)
        write(io, base64decode(resp["result"]["data"]))
    end
    nothing
end
