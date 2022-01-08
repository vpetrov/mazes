extends Node

func element(a:Array):
    if a == null || a.empty():
        return null
        
    var random_index = floor(rand_range(0, a.size()))
    return a[random_index]
