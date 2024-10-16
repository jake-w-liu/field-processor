using RadiationPatterns
using CSV
using DataFrames
using FFMPEG
using PlotlyJS
using Infiltrator
# using Thread.@threads


folder_name = "./tmp/const/1600/"


function read_interface(name, ds = 1, sq = true)
    df = CSV.read(name, DataFrame; header=false)
    ny = length(df.Column2)
    nx = 1
    U = Matrix(transpose(reshape(df.Column3, (ny, nx))))
    U .= abs.(U) 
    if sq
        U .= U.^2
    end
    x = [0.0]
    y = collect(range(-ny/2*ds, ny/2*ds, ny))
    Pat = Pattern(U, x, y)
    return Pat
end

function process_interface(folder_name)
    name = folder_name * "interface_amp.dat" 
    intf = read_interface(name, 1/3, false)
    name = folder_name * "interface_amp_pi.dat" 
    intp = read_interface(name, 1/3, false)
    # @infiltrate
    fig = ptn_2d(
        [intp, intf],
        dims=2,
        name=["playback", "forward"],
        mode=["lines", "dash"],
        color=["red", "blue"],
        xlabel="position (µm)",
        ylabel="amplitude (a.u.)",
    )
    fig.plot.layout.height = 500
    fig.plot.layout.width = 600
    fig.plot.layout.legend = attr(xanchor = "right", yanchor = "top", x = 0.98, y = 0.95)
    fig.plot.data[1].line = attr(width=0.8) 
    fig.plot.data[2].line = attr(width=0.8, dash="dash") 
    react!(fig, fig.plot.data, fig.plot.layout)

    savefig(
        fig,
        folder_name * "interface_plot.png" ;
        height = 500,
        width = 600,
    )

    fig = ptn_2d(
        [intp, intf],
        dims=2,
        # name=["playback", "forward"],
        mode=["lines", "dash"],
        color=["red", "blue"],
        xlabel="(µm)",
        # ylabel="amplitude (a.u.)",
        xrange = [-20, 20],
    )
    fig.plot.layout.showlegend = false
    # fig.plot.layout.legend = attr(xanchor = "right", yanchor = "top", x = 0.98, y = 0.95)
    fig.plot.data[1].line = attr(width=1) 
    fig.plot.data[2].line = attr(width=1, dash="dash") 
    react!(fig, fig.plot.data, fig.plot.layout)

    savefig(
        fig,
        folder_name * "interface_plot_zoom.png" ;
        height = 400,
        width = 440,
    )
    return nothing
end

process_interface(folder_name)
