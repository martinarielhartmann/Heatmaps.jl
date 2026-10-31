module Heatmaps
using Makie,CairoMakie,DataFrames,LinearAlgebra,Statistics,HypothesisTests
import Base: *

export heatmap
include("heatmap.jl")
end # module Heatmaps
