using CSV, DataFrames, GLMakie, Dates, UnicodeFun
using PlotUtils: optimize_ticks

# load data
data = DataFrame(CSV.File(joinpath("input","ATMOS484.csv")))

fig = Figure()
ax = Axis(fig[1,1], xlabel = to_latex("\\theta (m^3 m^{-3})"), ylabel = "depth (cm)")

#sl = Slider(fig[2, 1], range = 20000:1:53100, startvalue = 20000)
#s = sl.value
s = Observable(20000)

dots = @lift([data.SWC_43[$s], data.SWC_30cm[$s], data.SWC_50cm[$s]])
dots_past1 = @lift([data.SWC_43[$s - 48*1], data.SWC_30cm[$s - 48*1], data.SWC_50cm[$s - 48*1]]) # 1 day
dots_past2 = @lift([data.SWC_43[$s - 48*2], data.SWC_30cm[$s - 48*2], data.SWC_50cm[$s - 48*2]]) # 2 day
dots_past3 = @lift([data.SWC_43[$s - 48*3], data.SWC_30cm[$s - 48*3], data.SWC_50cm[$s - 48*3]]) # 3 day
dots_past4 = @lift([data.SWC_43[$s - 48*4], data.SWC_30cm[$s - 48*4], data.SWC_50cm[$s - 48*4]]) # 4 day
dots_past5 = @lift([data.SWC_43[$s - 48*5], data.SWC_30cm[$s - 48*5], data.SWC_50cm[$s - 48*5]]) # 5 day
dots_past6 = @lift([data.SWC_43[$s - 48*6], data.SWC_30cm[$s - 48*6], data.SWC_50cm[$s - 48*6]]) # 6 day
dots_past7 = @lift([data.SWC_43[$s - 48*7], data.SWC_30cm[$s - 48*7], data.SWC_50cm[$s - 48*7]]) # 7 day

scatter!(ax, dots, [15, 30, 50], color = RGBAf(0,0,0,1))
lines!(ax, dots, [15, 30, 50], color =  RGBAf(0,0,0,1))

scatter!(ax, dots_past1, [15, 30, 50], color = RGBAf(0,0,0,0.8))
lines!(ax, dots_past1, [15, 30, 50], color = RGBAf(0,0,0,0.8))

scatter!(ax, dots_past2, [15, 30, 50], color = RGBAf(0,0,0,0.6))
lines!(ax, dots_past2, [15, 30, 50], color = RGBAf(0,0,0,0.6))

scatter!(ax, dots_past3, [15, 30, 50], color = RGBAf(0,0,0,0.5))
lines!(ax, dots_past3, [15, 30, 50], color = RGBAf(0,0,0,0.5))

scatter!(ax, dots_past4, [15, 30, 50], color = RGBAf(0,0,0,0.4))
lines!(ax, dots_past4, [15, 30, 50], color = RGBAf(0,0,0,0.4))

scatter!(ax, dots_past5, [15, 30, 50], color = RGBAf(0,0,0,0.3))
lines!(ax, dots_past5, [15, 30, 50], color = RGBAf(0,0,0,0.3))

scatter!(ax, dots_past6, [15, 30, 50], color = RGBAf(0,0,0,0.2))
lines!(ax, dots_past6, [15, 30, 50], color = RGBAf(0,0,0,0.2))

scatter!(ax, dots_past7, [15, 30, 50], color = RGBAf(0,0,0,0.1))
lines!(ax, dots_past7, [15, 30, 50], color = RGBAf(0,0,0,0.1))

#scatter!(ax, [SWC_15cm[30000], SWC_30cm[30000], SWC_50cm[30000]], [15, 30, 50])
#lines!(ax, [SWC_15cm[30000], SWC_30cm[30000], SWC_50cm[30000]], [15, 30, 50])

xlims!(ax, 0, 0.5)
ylims!(ax, 0, 55)
ax.yreversed = true
#ax.title = @lift(data.datetime[$s])
test = @lift(Dates.format(data.datetime[$s], "dd/mm/yyyy"))
supertitle = Label(fig[0, :], test, textsize = 30, tellwidth = false, tellheight = true)

ax2 = Axis(fig[2, 1], ylabel = to_latex("\\theta (m^3 m^{-3})"), xlabel = "Month")

cm15 = @lift(Point2f.(datetime2unix.(data.datetime[20000:48:$s]), data.SWC_43[20000:48:$s]))
cm30 = @lift(Point2f.(datetime2unix.(data.datetime[20000:48:$s]), data.SWC_30cm[20000:48:$s]))
cm50 = @lift(Point2f.(datetime2unix.(data.datetime[20000:48:$s]), data.SWC_50cm[20000:48:$s]))

lines!(ax2, cm15)
lines!(ax2, cm30)
lines!(ax2, cm50)

#dateticks = optimize_ticks(data.datetime[20000], data.datetime[end])[1]
dateticks = collect(DateTime(2020,11,01):Month(1):DateTime(2022,09,01))
ax2.xticks[] = (datetime2unix.(dateticks), Dates.format.(dateticks, "mm"));

xlims!(ax2, datetime2unix(data.datetime[20000]), datetime2unix(data.datetime[53100]))
ylims!(ax2, 0, 0.5)

# sum of daily precip
precip = Float64[]
datep = []
j = 20000
while j < size(data)[1]-48
  push!(precip, sum(skipmissing(data.Precip[j:j+48]))) 
  push!(datep, data.datetime[j])
  j += 48
end

ax3 = Axis(fig[2, 1], yaxisposition = :right, ylabel = to_latex("precip (mm day^{-1})"))
hidespines!(ax3)
hidexdecorations!(ax3)

GLMakie.barplot!(ax3, datetime2unix.(datep), precip, color = :black)
xlims!(ax3, datetime2unix(datep[0]), datetime2unix(datep[end])) 
ylims!(ax3, 0, 180)


framerate = 10
timestamps = 20000:48:53100

record(fig, joinpath("output", "time_animation.mp4"), timestamps;
        framerate = framerate) do t
    s[] = t
end





