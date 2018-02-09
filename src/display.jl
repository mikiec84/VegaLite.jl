######################################################################
#
#    Initializations and settings for plot display
#
######################################################################

struct IDEDisplay <: Display ; end
struct BrowserDisplay <: Display ; end
struct BlinkDisplay <: Display ; end


function __init__()
  pushdisplay(BrowserDisplay())
  pushdisplay(BlinkDisplay())
  # println(Base.Multimedia.displays)
end

# function display(::IDEDisplay, plt::VLSpec{:plot})
#   # decline if not possible
#
# end

function Base.Multimedia.display(::BrowserDisplay, plt::VLSpec{:plot})
  checkplot(plt)
  tmppath = writehtml_full(JSON.json(plt.params))
  launch_browser(tmppath) # Open the browser
end

# @require Blink begin  # only if/when Blink is loaded
  import Blink

  global win = nothing
  global idcounter = 1

  function initwindow()
    global win

    win = Blink.Window(); sleep(1)
    Blink.opentools(win); sleep(1)

    Blink.load!(win, "C:/Users/frtestar/.julia/v0.6/VegaLite/deps/lib/vega.min.js")
    Blink.load!(win, "C:/Users/frtestar/.julia/v0.6/VegaLite/deps/lib/vega-lite.min.js")
    Blink.load!(win, "C:/Users/frtestar/.julia/v0.6/VegaLite/deps/lib/vega-embed.min.js")

    styleexp = :( begin
      @var styl = document.createElement("style")
      styl.media = "screen"
      styl.innerHTML = ".vega-actions a {
        margin-right: 10px;
        font-family: sans-serif;
        font-size: x-small;
        font-style: italic;
      }"
      document.head.appendChild(styl)
    end )
    Blink.js_(win, styleexp)

    Blink.body!(win, "")
    sleep(1)
  end

  function Base.Multimedia.display(::BlinkDisplay, plt::VLSpec{:plot})
    global win, idcounter
    checkplot(plt)

    ( (win == nothing) || !Blink.active(win) ) && initwindow()

    idstr = "vgplot$idcounter"
    idcounter += 1
    optdict = Dict(:mode=>"vega-lite", :renderer=>RENDERER, :actions=>ACTIONSLINKS)
    jscode = :(begin
      opt = $optdict

      @var div = document.createElement("div")
      div.id = $idstr
      div.class = "vega-embed"
      document.body.appendChild(div)

      spec = $(plt.params)
      vegaEmbed($("#" * idstr), spec, opt)
      document.querySelector($("#" * idstr)).scrollIntoView()
    end )

    Blink.js_(win, jscode)
    nothing
  end

# end


@require Juno begin  # only if/when Juno is loaded

  import Juno

  # media(VLSpec)
  # media(VLSpec, Media.Plot)
  function Juno.render(i::Juno.Inline, plt::VLSpec{:plot})
    display(plt)
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
