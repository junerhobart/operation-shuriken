local levels = {}

levels.data = {
    [1]  = require("src.levels.level1"),
    [2]  = require("src.levels.level2"),
    [3]  = require("src.levels.level3"),
    [4]  = require("src.levels.level4"),
    [5]  = require("src.levels.level5"),
    [6]  = require("src.levels.level6"),
    [7]  = require("src.levels.level7"),
    [8]  = require("src.levels.level8"),
    [9]  = require("src.levels.level9"),
    [10] = require("src.levels.level10"),
    [11] = require("src.levels.level11"),
    [12] = require("src.levels.level12"),
}

levels.totalLevels = 12

function levels.get(n)
    return levels.data[n]
end

return levels
