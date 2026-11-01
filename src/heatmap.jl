""""
Heatmap for symmetric DataFrame such as a correlation matrix. If `get_cor` is set to `true`, a correlation matrix and p-values are computed from the DataFrame.
"""
function heatmap(df::DataFrame;label="",get_cor=false)
    if get_cor
        vnames = names(df)
        x = Matrix(df)
        p = size(x,2)
        df_cor = DataFrame(cor(x),vnames)
        p = [pvalue(CorrelationTest(x[:, i], x[:, j])) for i in 1:p, j in 1:p]
        Heatmaps.heatmap(df_cor,p;label=label)
    else
        heatmap_(df::DataFrame;label="")
    end
end

""""
Heatmap for symmetric DataFrame such as a correlation matrix.
"""
function heatmap_(df::DataFrame;label="")
    s = size(df)
    s[1] !== s[2] ? error("Expected to see symmetric data") : Nothing
    l = s[1]
    tl = names(df)
    dn = Matrix(df)
    d = string.(round.(dn, digits = 2))
    d[tril(trues(size(d)))] .= ""
    fig = Figure(size = (1200, 1200))
    ax = Axis(fig[1, 1], xticks = (1:l,tl), yticks = (1:l,tl))
    ax.xticklabelsize = Heatmaps.fontsize(s[1])
    ax.yticklabelsize = Heatmaps.fontsize(s[1])
    hmap = heatmap!(ax, dn, colormap = :plasma)
    for i in 1:size(d,1), j in 1:size(d,2)
        txtcolor = dn[i, j] < 0.15 ? :white : :black
        text!(ax, d[i,j], position = (i, j),
            color = txtcolor, align = (:center, :center),fontsize=Heatmaps.fontsize(s[1]))
    end
    hmap.image.value.x[tril(trues(size(hmap.image.value.x)),-1)] .=NaN
    Colorbar(fig[1, 2], hmap; label = "", width = 15, ticksize = 15)
    ax.xticklabelrotation = π / 3
    ax.xticklabelalign = (:right, :center)
    return fig
end
"""
Heatmap for symmetric DataFrame (such as a correlation matrix) and an array of p-values.
"""

function heatmap(df::DataFrame,m::Matrix{Float64};label="")
    s = size(df)
    s2 = size(m)
    s[1] !== s[2] ? error("Expected to see symmetric data") : Nothing
    s2[1] !== s2[2] ? error("Expected to see symmetric data") : Nothing
    s !== s2 ? error("Expected two identically sized matrices") : Nothing
    l = s[1]
    tl = names(df)
    dn = Matrix(df)
    d = string.(round.(dn, digits = 2))
    d[tril(trues(size(d)))] .= ""
    ptext = Matrix{String}(undef,l,l)
    m[tril(trues(size(m)))] .=1
    st = p_to_stars.(m)
    fig = Figure(size = (1800, 1800))
    ax = Axis(fig[1, 1], xticks = (1:l,tl), yticks = (1:l,tl))
    ax.xticklabelsize = Heatmaps.fontsize(s[1])
    ax.yticklabelsize = Heatmaps.fontsize(s[1])
    hmap = heatmap!(ax, dn, colormap = :plasma)
    for i in 1:size(d,1), j in 1:size(d,2)
        txtcolor = dn[i, j] < 0.15 ? :white : :black
        text!(ax, st[i,j]*"\n"*d[i,j], position = (i, j),
            color = txtcolor, align = (:center, :center),fontsize = Heatmaps.fontsize(s[1]))
    end
    hmap.image.value.x[tril(trues(size(hmap.image.value.x)),-1)] .=NaN

    Colorbar(fig[1, 2], hmap; label = "", width = 15, ticksize = 15)
    ax.xticklabelrotation = π / 3
    ax.xticklabelalign = (:right, :center)
    return fig
end
function p_to_stars(p)
    if p < 0.001
        return "***"
    elseif p < 0.01
        return "**"
    elseif p < 0.05
        return "*"
    else
        return ""
    end
end
fontsize(n) = round(125/(n^0.4))
