module FoodJl

mutable struct Food
    x::Int64
    y::Int64
    L::Int64

    function Food(L)
        new(L, rand(1:L), rand(1:L))
    end
end

end
