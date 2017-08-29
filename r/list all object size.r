#get all object sizes
head(sort(sapply(ls(),function(x){object.size(get(x))}),decreasing = T))
