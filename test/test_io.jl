using Base.Test
using VegaLite
using DataFrames

p = VegaLite.data(DataFrame(x = [1,2,3], y=[1,2,3])) |>
    markpoint() |>
    encoding(xquantitative(field=:x), yquantitative(field=:y))

Base.Filesystem.mktempdir() do folder
    fn = joinpath(folder,"test1.svg")
    svg(fn, p)
    @test isfile(fn)
    @test stat(fn).size > 5000

    fn = joinpath(folder,"test1.pdf")
    pdf(fn, p)
    @test isfile(fn)
    @test stat(fn).size > 5000

    fn = joinpath(folder,"test1.png")
    png(fn, p)
    @test isfile(fn)
    @test stat(fn).size > 5000

    fn = joinpath(folder,"test1.jpg")
    jpg(fn, p)
    @test isfile(fn)
    @test stat(fn).size > 5000


    fn = joinpath(folder,"test2.svg")
    save(fn, p)
    @test isfile(fn)
    @test stat(fn).size > 5000

    fn = joinpath(folder,"test2.pdf")
    save(fn, p)
    @test isfile(fn)
    @test stat(fn).size > 5000

    fn = joinpath(folder,"test2.png")
    save(fn, p)
    @test isfile(fn)
    @test stat(fn).size > 5000

    fn = joinpath(folder,"test2.jpg")
    save(fn, p)
    @test isfile(fn)
    @test stat(fn).size > 5000

end
