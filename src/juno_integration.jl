######################################################################
#
#     Juno Integration
#
######################################################################

struct IDEDisplay <: Display ; end
struct BrowserDisplay <: Display ; end
struct BlinkDisplay <: Display ; end

# pushdisplay(IDEDisplay())
# popdisplay(IDEDisplay())
# Base.Multimedia.displays

pushdisplay(BrowserDisplay())
pushdisplay(BlinkDisplay())


# function display(::IDEDisplay, plt::VLSpec{:plot})
#   # decline if not possible
# 
# end

function Base.Multimedia.display(::BrowserDisplay, plt::VLSpec{:plot})
  checkplot(plt)
  tmppath = writehtml_full(JSON.json(plt.params))
  launch_browser(tmppath) # Open the browser
end

if Pkg.installed("Blink") != nothing
  using Blink

  global win = nothing
  global idcounter = 1

  function Base.Multimedia.display(::BlinkDisplay, plt::VLSpec{:plot})
    global win, idcounter
    checkplot(plt)

    if (win == nothing) || !active(win)
      win = Window()
      opentools(w)

      load!(win, "C:/Users/frtestar/.julia/v0.6/VegaLite/deps/lib/vega.min.js")
      load!(win, "C:/Users/frtestar/.julia/v0.6/VegaLite/deps/lib/vega-lite.min.js")
      load!(win, "C:/Users/frtestar/.julia/v0.6/VegaLite/deps/lib/vega-embed.min.js")
    end

    @js_ w opt = Dict(:mode=>"vega-lite",
                      :renderer=> RENDERER,
                      :actions=> ACTIONSLINKS)

    idstr = "vgplot$idcounter"
    idcounter += 1
    @js_ win begin
      @var div = document.createElement("div")
      div.id = idstr
      div.class = "vega-embed"
      document.body.appendChild(div)
    end
    # body!(win, "<div id='$idstr'></div>")
    @js_ win spec = $(plt.params)
    @js_ w vegaEmbed($("#$idstr"), spec2, opt)
  end
end


@require Juno begin  # only if/when Juno is loaded

import Juno

# media(VLSpec)
# media(VLSpec, Media.Plot)
# media(VLSpec, Media.Textual)

function Juno.render(i::Juno.Inline, plt::VLSpec{:plot})
  display(plt)
  # checkplot(plt)
  # tmppath = writehtml_full(JSON.json(plt.params))
  # launch_browser(tmppath) # Open the browser
  Juno.render(i, nothing) # print nothing in the editor pane
end

end


# using Juno
#
# media(VLSpec, Media.Plot)
#
# Juno.@render Juno.PlotPane p::VLSpec begin
#     HTML(stringmime("image/svg+xml", p))
# end
