#=
Refueling Problem
=#

using StaticArrays
using LinearAlgebra
using Random
using POMDPs
using POMDPModels
using POMDPModelTools
using Compose
using ColorSchemes
using Parameters
using BeliefUpdaters


#slippery

@with_kw struct RefuelPOMDPExplicit06 <: POMDP{Int, Int, Int}
    slippery::Float64                  = 0.3
    obsdict::Dict{Int, Int}            = ObservationDict()
    act0dict::Dict{Int, Vector{Int}}   = TransitionDictAct0()
    act1dict::Dict{Int,  Vector{Int}}           = TransitionDictAct1()
    act2dict::Dict{Int,  Vector{Int}}           = TransitionDictAct2()
    act3dict::Dict{Int,  Vector{Int}}           = TransitionDictAct3()
end


## States 

POMDPs.length(pomdp::RefuelPOMDPExplicit06) = 209

POMDPs.states(pomdp::RefuelPOMDPExplicit06) = 1:209

POMDPs.stateindex(pomdp::RefuelPOMDPExplicit06, s::Int) = s

function POMDPs.initialstate(pomdp::RefuelPOMDPExplicit06)
    return Deterministic(1)
end


function TransitionDictAct0()
    dict = Dict{Int, Vector{Int}}()
    dict[0] = [1]
    dict[1] = [2,3]
    dict[2] = [7,8]
    dict[3] = [8,12]
    dict[4] = [9,13]
    dict[5] = [10, 14]
    dict[6] = [1]
    dict[7] = [21, 22]
    dict[8] = [22,26]
    dict[9] = [23,27]
    dict[10] = [24,28]
    dict[11] = [25, 21]
    dict[12] = [26,35]
    dict[13] = [27,36]
    dict[14] = [39]
    dict[15] = [30, 24]
    dict[16] = [31, 38]
    dict[17] = [33, 43]
    dict[18] = [34, 23]
    dict[19] = [46, 47]
    dict[20] = [1]
    dict[21] = [51, 52]
    dict[22] = [52, 55]
    dict[23] = [53, 56]
    dict[24] = [39]
    dict[25] = [47, 51]
    dict[26] = [55]
    dict[27] = [56, 62]
    dict[28] = [57, 63]
    dict[29] = [48, 61]
    dict[30] = [59, 54]
    dict[31] = [60, 64]
    dict[32] = [49, 59]
    dict[33] = [72, 65]
    dict[34] = [61, 53]
    dict[35] = [74, 75]
    dict[36] = [62, 74]
    dict[37] = [63, 75]
    dict[38] = [64, 76]
    dict[39] = [80, 81]
    dict[40] = [68, 60]
    dict[41] = [69, 72]
    dict[42] = [70, 78]
    dict[43] = [65, 77]
    dict[44] = [73, 87]
    dict[45] = [1]
    dict[46] = [90, 91]
    dict[47] = [91, 95]
    dict[48] = [92, 96]
    dict[49] = [93, 97]
    dict[50] = [94, 90]
    dict[51] = [95, 104]
    dict[52] = [104]
    dict[53] = [105, 107]
    dict[54] = [106, 108]
    dict[55] = [111, 112]
    dict[56] = [107, 111]
    dict[57] = [108, 112]
    dict[58] = [103, 92]
    dict[59] = [39]
    dict[60] = [109, 113]
    dict[61] = [96,105]
    dict[62] = [111]
    dict[63] = [112]
    dict[64] = [113, 119]
    dict[65] = [114, 120]
    dict[66] = [99, 93]
    dict[67] = [100, 118]
    dict[68] = [118, 109]
    dict[69] = [116, 110]
    dict[70] = [117,121]
    dict[71] = [102, 116]
    dict[72] = [110, 114]
    dict[73] = [128, 122]
    dict[74] = [112, 129]
    dict[75] = [129, 130]
    dict[76] = [119, 129]
    dict[77] = [132]
    dict[78] = [121, 131]
    dict[79] = [14, 133]
    dict[80] = [136, 137]
    dict[81] = [137, 141]
    dict[82] = [138, 142]
    dict[83] = [139, 143]
    dict[84] = [140, 144]
    dict[85] = [125, 117]
    dict[86] = [126, 128]
    dict[87] = [122, 149]
    dict[88] = [88]
    dict[89] = [1]
    dict[90] = [90]
    dict[91] = [91]
    dict[92] = [92]
    dict[93] = [39]
    dict[94] = [94]
    dict[95] = [95]
    dict[96] = [96]
    dict[97] = [97]
    dict[98] = [98]
    dict[99] = [99]
    dict[100] = [100]
    dict[101] = [101]
    dict[102] = [102]
    dict[103] = [103]
    dict[104] = [104]
    dict[105] = [105]
    dict[106] = [106]
    dict[107] = [107]
    dict[108] = [108]
    dict[109] = [109]
    dict[110] = [110]
    dict[111] = [111]
    dict[112] = [112]
    dict[113] = [113]
    dict[114] = [132]
    dict[115] = [115]
    dict[116] = [116]
    dict[117] = [117]
    dict[118] = [118]
    dict[119] = [119]
    dict[120] = [120]
    dict[121] = [121]
    dict[122] = [122]
    dict[123] = [123]
    dict[124] = [124]
    dict[125] = [125]
    dict[126] = [126]
    dict[127] = [127]
    dict[128] = [128]
    dict[129] = [129]
    dict[130] = [130]
    dict[131] = [131]
    dict[132] = [151, 152]
    dict[133] = [37, 156]
    dict[134] = [38, 157]
    dict[135] = [43, 158]
    dict[136] = [156, 161]
    dict[137] = [161]
    dict[138] = [162, 164]
    dict[139] = [163, 165]
    dict[140] = [36, 166]
    dict[141] = [169, 170]
    dict[142] = [164, 169]
    dict[143] = [132]
    dict[144] = [166, 171]
    dict[145] = [158, 163]
    dict[146] = [167, 172]
    dict[147] = [168, 175]
    dict[148] = [157,162]
    dict[149] = [149]
    dict[150] = [143, 176]
    dict[151] = [179]
    dict[152] = [183, 184]
    dict[153] = [180, 183]
    dict[154] = [181, 184]
    dict[155] = [182, 185]
    dict[156] = [75]
    dict[157] = [76, 188]
    dict[158] = [77, 189]
    dict[159] = [78, 190]
    dict[160] = [87, 191]
    dict[161] = [192, 193]
    dict[162] = [188, 192]
    dict[163] = [132]
    dict[164] = [192]
    dict[165] = [193]
    dict[166] = [74]
    dict[167] =[194, 195]
    dict[168] = [197, 196]
    dict[169] = [193, 198]
    dict[170] = [198, 199]
    dict[171] = [75, 192]
    dict[172] = [195, 198]
    dict[173] = [190, 194]
    dict[174] = [191, 197]
    dict[175] = [196, 199]
    dict[176] = [170]
    dict[177] = [172, 200]
    dict[178] = [175, 201]
    dict[179] = [202, 203]
    dict[180] = [202]
    dict[181] = [203]
    dict[182] = [169]
    dict[183] = [203]
    dict[184] = [184]
    dict[185] = [170, 202]
    dict[186] = [201, 203]
    dict[187] = [200, 202]
    dict[188] = [129]
    dict[189] = [130]
    dict[190] = [131, 204]
    dict[191] = [149, 205]
    dict[192] = [130, 206]
    dict[193] = [206, 207]
    dict[194] = [204, 206]
    dict[195] = [206]
    dict[196] = [207]
    dict[197] = [205, 207]
    dict[198] = [207]
    dict[199] = [199]
    dict[200] = [198]
    dict[201] = [199]
    dict[202] = [199]
    dict[203] = [203]
    dict[204] = [204]
    dict[205] = [205]
    dict[206] = [206]
    dict[207] = [207]

    return dict
end


function TransitionDictAct1()

    dict = Dict{Int, Vector{Int}}()

    dict[1] = [4, 5]
    dict[2] = [9, 10]
    dict[3] = [13, 14]
    dict[4] = [15, 16]
    dict[5] = [16, 17]

    dict[7] = [23, 24]
    dict[8] = [27, 28]
    dict[9] = [30, 31]
    dict[10] =[31, 33]
    dict[11] = [34, 30]
    dict[12] = [36, 37]
    dict[13] = [24, 38]

    dict[15] = [40, 41]
    dict[16] = [41, 42]
    dict[17] = [42, 44]
    dict[18] = [32, 40]
    dict[19] = [48, 49]

    dict[21] = [53, 54]
    dict[22] = [56, 57]
    dict[23] = [59, 60]

    dict[25] = [61, 59]
    dict[26] = [62, 63]
    dict[27] = [54, 64]
    dict[28] = [64, 65]
    dict[29] = [66, 67]
    dict[30] = [68, 69]
    dict[31] = [69, 70]
    dict[32] = [67, 71]
    dict[33] = [70, 73]
    dict[34] = [49, 68]
    dict[35] = [52, 51]
    dict[36] = [57, 76]
    dict[37] = [76, 77]
    dict[38] = [72, 78]
    dict[39] = [82, 83]
    dict[40] = [71, 85]
    dict[41] = [85, 86]
    dict[42] = [86]
    dict[43] = [78, 87]
    dict[44] = [85, 71]

    dict[46] = [92, 93]
    dict[47] = [96, 97]
    dict[48] = [99, 100]
    dict[49] = [100, 102]
    dict[50] = [103, 99]
    dict[51] = [105, 106]
    dict[52] = [107, 108]
    dict[53] = [97, 109]
    dict[54] = [109, 110]
    dict[55] = [95, 91]
    dict[56] = [106, 113]
    dict[57] = [113, 114]
    dict[58] = [101, 115]

    dict[60] = [116, 117]
    dict[61] = [93, 118]
    dict[62] = [108, 119]
    dict[63] = [119, 120]
    dict[64] = [110, 121]
    dict[65] = [121, 122]
    dict[66] = [115, 123]
    dict[67] = [123, 124]
    dict[68] = [102, 125]
    dict[69] = [125, 126]
    dict[70] = [126]
    dict[71] = [124, 127]
    dict[72] = [117, 128]
    dict[73] = [127]
    dict[74] = [107, 105]
    dict[75] = [108, 106]
    dict[76] = [114, 131]

    dict[78] = [128]
    dict[79] = [134, 135]
    dict[80] = [138, 139]
    dict[81] = [142, 143]
    dict[82] = [145, 146]
    dict[83] = [146, 147]
    dict[84] = [14, 148]
    dict[85] = [127]
    dict[86] = [124, 123]
    dict[87] = [126, 127]

    dict[132] = [153, 154]
    dict[133] = [157, 158]
    dict[134] = [33, 159]
    dict[135] = [159, 160]
    dict[136] = [162, 163]
    dict[137] = [164, 165]
    dict[138] = [158, 167]
    dict[139] = [167, 168]
    dict[140] = [28, 157]
    dict[141] = [156, 37]
    dict[142] = [163, 172]

    dict[144] = [37, 162]
    dict[145] = [173, 174]
    dict[146] = [174]
    dict[147] = [160, 44]
    dict[148] = [43, 173]

    dict[150] = [177, 178]
    dict[151] = [180, 181]
    dict[152] = [176, 143]
    dict[153] = [186]
    dict[154] = [178, 147]
    dict[155] = [143, 187]
    dict[156] = [188, 189]
    dict[157] = [65, 190]
    dict[158] = [190, 191]
    dict[159] = [73]
    dict[160] = [86]
    dict[161] = [63, 57]
    dict[162] = [77, 194]

    dict[164] = [189,195]
    dict[165] = [195, 196]
    dict[166] = [63, 188]
    dict[167] = [191]
    dict[168] = [87, 73]
    dict[169] = [188, 76]
    dict[170] = [189, 77]
    dict[171] = [62, 56]
    dict[172] = [197]
    dict[173] = [87]
    dict[174] = [73, 86]
    dict[175] = [191, 87]
    dict[176] = [200, 201]
    dict[177] = [168]
    dict[178] = [174, 160]
    dict[179] = [165, 163]
    dict[180] = [201]
    dict[181] = [175, 168]
    dict[182] = [165, 200]
    dict[183] = [200, 172]

    dict[185] = [164, 162]
    dict[186] = [168, 174]
    dict[187] = [175]
    dict[188] = [120, 204]
    dict[189] = [204, 205]
    dict[190] = [122]
    dict[191] = [128, 126]
    dict[192] = [119, 113]
    dict[193] = [120, 114]
    dict[194] = [149]
    dict[195] = [205]
    dict[196] = [149, 122]
    dict[197] = [122, 128]
    dict[198] = [204, 131]

    dict[200] = [196]
    dict[201] = [197, 191]
    dict[202] = [195, 194]

    return dict
end


function TransitionDictAct2()
    dict = Dict{Int, Vector{Int}}()

    dict[2] = [6]
    dict[3] = [11,6]
    dict[4] = [6]
    dict[5] = [18,6]

    dict[7] = [19, 20]
    dict[8] = [25,19]
    dict[9] = [29]
    dict[10] = [32]
    dict[11] = [20]
    dict[12] = [21, 25]
    dict[13] = [34, 29]

    dict[15] = [29,20]
    dict[16] = [32,29]
    dict[17] = [40,32]
    dict[18] = [20]
    dict[19] = [45]

    dict[21] = [46, 50]
    dict[22] = [47, 46]
    dict[23] = [48, 58]

    dict[25] = [50, 45]
    dict[26] = [51, 47]
    dict[27] = [61,48]
    dict[28] = [59, 49]
    dict[29] = [45]
    dict[30] = [66]
    dict[31] = [67]
    dict[32] = [58, 45]
    dict[33] = [71]
    dict[34] = [58]

    dict[36] = [53, 61]
    dict[37] = [54, 59]
    dict[38] = [68, 67]
    dict[39] = [79, 5]
    dict[40] = [66, 58]
    dict[41] = [67, 66]
    dict[42] = [71, 67]
    dict[43] = [69, 71]

    dict[46] = [88, 89]
    dict[47] = [94, 88]
    dict[48] = [98]
    dict[49] = [101]
    dict[50] = [89]
    dict[51] = [90, 94]
    dict[52] = [91, 90]
    dict[53] = [92, 103]
    dict[54] = [93, 99]

    dict[56] = [96, 92]
    dict[57] = [97, 93]
    dict[58] = [89]

    dict[60] = [100, 115]
    dict[61] = [103, 98]
    dict[62] = [105, 96]
    dict[63] = [106, 97]
    dict[64] = [118, 100]
    dict[65] = [116, 102]
    dict[66] = [98, 89]
    dict[67] = [101, 98]
    dict[68] = [115]
    dict[69] = [123]
    dict[70] = [124]
    dict[71] = [115, 101]
    dict[72] = [102, 123]
    dict[73] = [125, 102]
    dict[74] = [104]
    dict[75] = [111, 104]
    dict[76] = [109, 118]

    dict[78] = [125, 124]
    dict[79] = [15]
    dict[80] = [14, 10]
    dict[81] = [133, 14]
    dict[82] = [134, 16]
    dict[83] = [135, 17]
    dict[84] = [9, 18]
    dict[85] = [123, 115]

    dict[87] = [117, 116]

    dict[132] = [150, 83]
    dict[133] = [24, 30]
    dict[134] = [40]
    dict[135] = [41]
    dict[136] = [28, 24]
    dict[137] = [37, 28]
    dict[138] = [38, 31]
    dict[139] = [43, 33]
    dict[140] = [23, 34]
    dict[141] = [171, 35]
    dict[142] = [157, 38]

    dict[144] = [27, 23]
    dict[145] = [33, 41]
    dict[146] = [159, 42]
    dict[147] = [173, 43]
    dict[148] = [31, 40]

    dict[150] = [145, 135]
    dict[151] = [143, 139]
    dict[152] = [185, 141]
    dict[153] = [177, 146]
    dict[154] = [187, 143]
    dict[155] = [138, 148]
    dict[156] = [57, 54]
    dict[157] = [60, 68]
    dict[158] = [72, 69]
    dict[159] = [85]
    dict[160] = [70, 69]
    dict[161] = [74, 55]
    dict[162] = [64, 60]

    dict[164] = [76, 64]
    dict[165] = [77, 65]
    dict[166] = [56, 53]
    dict[167] = [78, 70]
    dict[168] = [190, 65]
    dict[169] = [75, 74]
    dict[170] = [192, 75]
    dict[171] = [55]
    dict[172] = [190, 78]
    dict[173] = [70, 85]
    dict[174] = [78, 72]
    dict[175] = [194, 77]
    dict[176] = [163, 158]
    dict[177] = [173, 159]
    dict[178] = [167, 158]
    dict[179] = [169, 161]
    dict[180] = [172, 167]
    dict[181] = [200, 165]
    dict[182] = [162, 157]
    dict[183] = [170, 169]

    dict[185] = [161, 171]
    dict[186] = [172, 163]
    dict[187] = [167, 173]
    dict[188] = [113, 109]
    dict[189] = [114, 110]
    dict[190] = [117, 125]
    dict[191] = [121, 110]
    dict[192] = [112, 111]
    dict[193] = [129, 112]
    dict[194] = [121, 117]
    dict[195] = [131, 121]
    dict[196] = [204, 120]
    dict[197] = [131, 114]
    dict[198] = [130, 129]

    dict[200] = [194, 190]
    dict[201] = [195, 189]
    dict[202] = [193, 192]
    return dict
end


function TransitionDictAct3()
    dict = Dict{Int, Vector{Int}}()

    dict[9] = [19]
    dict[10] = [34, 19]

    dict[13] = [25]

    dict[23] = [46]

    dict[27] = [47]
    dict[28] = [53, 47]

    dict[30] = [48,50]
    dict[31] = [49, 48]

    dict[33] = [68, 49]
    dict[34] = [50]

    dict[36] = [51]
    dict[37] = [56, 51]
    dict[38] = [59,61]
    dict[39] = [84, 3]

    dict[43] = [60, 59]

    dict[48] = [88]
    dict[49] = [103, 88]

    dict[53] = [90]
    dict[54] = [96, 90]

    dict[56] = [91]
    dict[57] = [105, 91]

    dict[60] = [93, 92]
    dict[61] = [94]
    dict[62] = [95]
    dict[63] = [107, 95]
    dict[64] = [97, 96]
    dict[65] = [109, 97]

    dict[68] = [99,103]
    dict[69] = [100, 99]
    dict[70] = [102, 100]

    dict[72] = [118, 93]

    dict[76] = [106, 105]
    dict[78] = [116,118]
    dict[79] = [9,11]
    dict[80] = [140, 8]
    dict[81] = [144, 12]
    dict[82] = [14, 13]
    dict[83] = [148, 14]
    dict[84] = [7]


    dict[132] = [155, 81]
    dict[133] = [27, 21]
    dict[134] = [30,34]
    dict[135] = [31, 30]
    dict[136] = [36, 22]
    dict[137] = [166, 26]
    dict[138] = [28, 27]
    dict[139] = [157, 28]
    dict[140] = [21]
    dict[142] = [37, 36]
    dict[144] = [22]
    dict[145] = [38, 24]
    dict[146] = [43, 38]
    dict[148] = [24, 23]
    
    dict[150] = [138, 133]
    dict[151] = [182, 137]
    dict[153] = [143, 142]
    dict[155] = [136, 144]
    dict[156] = [62, 52]
    dict[157] = [54, 53]
    dict[158] = [64, 54]
    dict[159] = [69, 68]
    dict[162] = [57, 56]
    dict[164] = [63, 62]
    dict[165] = [188, 63]
    dict[166] = [52]
    dict[167] = [65, 64]
    dict[172] = [77, 76]
    dict[173] = [72, 60]
    dict[176] = [164, 156]
    dict[177] = [158, 157]
    dict[180] = [165, 164]
    dict[182] = [156, 166]
    dict[187] = [163, 162]
    dict[188] = [108, 107]
    dict[189] = [119, 108]
    dict[190] = [110, 109]
    dict[194] = [114, 113]
    dict[195] = [120, 119]
    dict[200] = [189, 188]

    return dict
end


function POMDPs.transition(pomdp::RefuelPOMDPExplicit06, s::Int, a::Int)

    probs = [1- pomdp.slippery, pomdp.slippery]
    dests = []
    if a == 1
        if haskey(pomdp.act0dict, s-1)
            dests = pomdp.act0dict[s-1]
        else
            dests = [208]
        end
    elseif a == 2
        if haskey(pomdp.act1dict, s-1)
            dests = pomdp.act1dict[s-1]
        else
            dests = [208]
        end
    elseif a == 3
        if haskey(pomdp.act2dict, s-1)
            dests = pomdp.act2dict[s-1]
        else
            dests = [208]
        end
    elseif a == 4
        if haskey(pomdp.act3dict, s-1)
            dests = pomdp.act3dict[s-1]
        else
            dests = [208]
        end
    end

    if length(dests) == 1
        return SparseCat([dests[1] + 1], [1.0])
    end

    return SparseCat(dests + [1,1], probs)
end

## Actions 

POMDPs.actions(pomdp::RefuelPOMDPExplicit06) = 1:4
POMDPs.actionindex(pomdp::RefuelPOMDPExplicit06, a::Int) = a

## Transition


function POMDPs.isterminal(m::RefuelPOMDPExplicit06, s::Int)
    
    if (s-1) in Set(184, 199, 203, 207, 180, 195, 200, 204)
        return true
    end

end

## Observation 

POMDPs.observations(pomdp::RefuelPOMDPExplicit06) = 1:51
POMDPs.obsindex(::RefuelPOMDPExplicit06, o::Int) = o

function POMDPs.initialobs(pomdp::RefuelPOMDPExplicit06, s) 
    return observations(pomdp, :up, s)
end


function ObservationDict()
    dict = Dict{Int, Int}()
    dict[0] = 27;
    dict[1] = 45;
    dict[2] = 14;
    dict[3] = 14;
    dict[4] = 44
    dict[5] = 44
    dict[6] = 36
    dict[7] = 18
    dict[8] = 18
    dict[9] = 6
    dict[10] = 6
    dict[11] = 18
    dict[12] = 18
    dict[13] = 6
    dict[14] = 7
    dict[15] = 8
    dict[16] = 8
    dict[17] = 8
    dict[18] = 8
    dict[19] = 1
    dict[20] = 47
    dict[21] = 1
    dict[22] = 1
    dict[23] = 16
    dict[24] = 25
    dict[25] = 1
    dict[26] = 1
    dict[27] = 16
    dict[28] = 16
    dict[29] = 3
    dict[30] = 16
    dict[31] = 16
    dict[32] = 3
    dict[33] = 16
    dict[34] = 16
    dict[35] = 41
    dict[36] = 16
    dict[37] = 16
    dict[38] = 16
    dict[39] = 31
    dict[40] = 3
    dict[41] = 3
    dict[42] = 3
    dict[43] = 16
    dict[44] = 28
    dict[45] = 34
    dict[46] = 17
    dict[47] = 17
    dict[48] = 12
    dict[49] = 12
    dict[50] = 17
    dict[51] = 17
    dict[52] = 17
    dict[53] = 12
    dict[54] = 12
    dict[55] = 19
    dict[56] = 12
    dict[57] = 12
    dict[58] = 20
    dict[59] = 35
    dict[60] = 12
    dict[61] = 12
    dict[62] = 12
    dict[63] = 12
    dict[64] = 12
    dict[65] = 12
    dict[66] = 20
    dict[67] = 20
    dict[68] = 12
    dict[69] = 12
    dict[70] = 12
    dict[71] = 20
    dict[72] = 12
    dict[73] = 11
    dict[74] = 40
    dict[75] = 40
    dict[76] = 12
    dict[77] = 35
    dict[78] = 12
    dict[79] = 13
    dict[80] = 13
    dict[81] = 13
    dict[82] = 13
    dict[83] = 13
    dict[84] = 13
    dict[85] = 20
    dict[86] = 5
    dict[87] = 11
    dict[88] = 21
    dict[89] = 30
    dict[90] = 21
    dict[91] = 21
    dict[92] = 0
    dict[93] = 15
    dict[94] = 21
    dict[95] = 21
    dict[96] = 0
    dict[97] = 0
    dict[98] = 4
    dict[99] = 0
    dict[100] = 0
    dict[101] = 4
    dict[102] = 0
    dict[103] = 0
    dict[104] = 32
    dict[105] = 0
    dict[106] = 0
    dict[107] = 0
    dict[108] = 0
    dict[109] = 0
    dict[110] = 0
    dict[111] = 9
    dict[112] = 9
    dict[113] = 0
    dict[114] = 15
    dict[115] = 4
    dict[116] = 0
    dict[117] = 0
    dict[118] = 0
    dict[119] = 0
    dict[120] = 0
    dict[121] = 0
    dict[122] = 26
    dict[123] = 4
    dict[124] = 4
    dict[125] = 0
    dict[126] = 26
    dict[127] = 39
    dict[128] = 26
    dict[129] = 9
    dict[130] = 9
    dict[131] = 0
    dict[132] = 31
    dict[133] = 6
    dict[134] = 6
    dict[135] = 6
    dict[136] = 6
    dict[137] = 6
    dict[138] = 6
    dict[139] = 6
    dict[140] = 6
    dict[141] = 10
    dict[142] = 6
    dict[143] = 7
    dict[144] = 6
    dict[145] = 6
    dict[146] = 6
    dict[147] = 22
    dict[148] = 6
    dict[149] = 26
    dict[150] = 13
    dict[151] = 13
    dict[152] = 46
    dict[153] = 13
    dict[154] = 38
    dict[155] = 13
    dict[156] = 16
    dict[157] = 16
    dict[158] = 16
    dict[159] = 16
    dict[160] = 24
    dict[161] = 23
    dict[162] = 16
    dict[163] = 25
    dict[164] = 16
    dict[165] = 16
    dict[166] = 16
    dict[167] = 16
    dict[168] = 24
    dict[169] = 23
    dict[170] = 23
    dict[171] = 23
    dict[172] = 16
    dict[173] = 16
    dict[174] = 24
    dict[175] = 24
    dict[176] = 6
    dict[177] = 6
    dict[178] = 22
    dict[179] = 10
    dict[180] = 43
    dict[181] = 22
    dict[182] = 6
    dict[183] = 10
    dict[184] = 29
    dict[185] = 10
    dict[186] = 22
    dict[187] = 6
    dict[188] = 12
    dict[189] = 12
    dict[190] = 12
    dict[191] = 11
    dict[192] = 40
    dict[193] = 40
    dict[194] = 12
    dict[195] = 48
    dict[196] = 11
    dict[197] = 11
    dict[198] = 40
    dict[199] = 49
    dict[200] = 2
    dict[201] = 24
    dict[202] = 23
    dict[203] = 33
    dict[204] = 42
    dict[205] = 26
    dict[206] = 9
    dict[207] = 37
    dict[208] = 50
    return dict
end

function POMDPs.observation(pomdp::RefuelPOMDPExplicit06, a, s)
    
    return Deterministic(pomdp.obsdict[s-1] + 1)
end

## Reward 
POMDPs.reward(pomdp::RefuelPOMDPExplicit06, s::Int) = 1.0
POMDPs.reward(pomdp::RefuelPOMDPExplicit06, s, a, sp) = reward(pomdp, s)
POMDPs.reward(pomdp::RefuelPOMDPExplicit06, s, a) = reward(pomdp, s)
POMDPs.discount(pomdp::RefuelPOMDPExplicit06) = 0.999

## distributions 
## helpers

function deterministic_belief(pomdp, s)
    b = zeros(length(states(pomdp)))
    si = stateindex(pomdp, s)
    b[si] = 1.0
    return DiscreteBelief(pomdp, b)
end


# function TransitionDictAct3(pomdp::RefuelPOMDPExplicit06)
#     prob = ([1-pomdp.slippery, pomdp.slippery])
#     dict = Dict{Int, Int}()
#     dict[0] = 1)
#     dict[1] = [2,3]
#     dict[2] = 
#     dict[3] = 
#     dict[4] = 
#     dict[5] = 
#     dict[6] = 
#     dict[7] = 
#     dict[8] = 
#     dict[9] = 
#     dict[10] =
#     dict[11] = 
#     dict[12] = 
#     dict[13] = 
#     dict[14] = 
#     dict[15] = 
#     dict[16] = 
#     dict[17] = 
#     dict[18] = 
#     dict[19] = 
#     dict[20] = 
#     dict[21] = 
#     dict[22] = 
#     dict[23] = 
#     dict[24] = 
#     dict[25] = 
#     dict[26] = 
#     dict[27] = 
#     dict[28] = 
#     dict[29] = 
#     dict[30] = 
#     dict[31] = 
#     dict[32] = 
#     dict[33] = 
#     dict[34] = 
#     dict[35] = 
#     dict[36] = 
#     dict[37] = 
#     dict[38] = 
#     dict[39] = 
#     dict[40] = 
#     dict[41] = 
#     dict[42] = 
#     dict[43] = 
#     dict[44] = 
#     dict[45] = 
#     dict[46] = 
#     dict[47] = 
#     dict[48] = 
#     dict[49] = 
#     dict[50] = 
#     dict[51] = 
#     dict[52] = 
#     dict[53] = 
#     dict[54] = 
#     dict[55] = 
#     dict[56] = 
#     dict[57] = 
#     dict[58] = 
#     dict[59] = 
#     dict[60] = 
#     dict[61] = 
#     dict[62] = 
#     dict[63] = 
#     dict[64] = 
#     dict[65] = 
#     dict[66] = 
#     dict[67] = 
#     dict[68] = 
#     dict[69] = 
#     dict[70] = 
#     dict[71] = 
#     dict[72] = 
#     dict[73] = 
#     dict[74] = 
#     dict[75] = 
#     dict[76] = 
#     dict[77] = 
#     dict[78] = 
#     dict[79] = 
#     dict[80] = 
#     dict[81] = 
#     dict[82] = 
#     dict[83] = 
#     dict[84] = 
#     dict[85] = 
#     dict[86] = 
#     dict[87] = 
#     dict[88] = 
#     dict[89] = 
#     dict[90] = 
#     dict[91] = 
#     dict[92] = 
#     dict[93] = 
#     dict[94] = 
#     dict[95] = 
#     dict[96] = 
#     dict[97] = 
#     dict[98] = 
#     dict[99] = 
#     dict[100] = 
#     dict[101] = 
#     dict[102] = 
#     dict[103] = 
#     dict[104] = 
#     dict[105] = 
#     dict[106] = 
#     dict[107] = 
#     dict[108] = 
#     dict[109] = 
#     dict[110] = 
#     dict[111] = 
#     dict[112] = 
#     dict[113] = 
#     dict[114] = 
#     dict[115] = 
#     dict[116] = 
#     dict[117] = 
#     dict[118] = 
#     dict[119] = 
#     dict[120] = 
#     dict[121] = 
#     dict[122] = 
#     dict[123] = 
#     dict[124] = 
#     dict[125] = 
#     dict[126] = 
#     dict[127] = 
#     dict[128] = 
#     dict[129] = 
#     dict[130] = 
#     dict[131] = 
#     dict[132] = 
#     dict[133] = 
#     dict[134] = 
#     dict[135] = 
#     dict[136] = 
#     dict[137] = 
#     dict[138] = 
#     dict[139] = 
#     dict[140] = 
#     dict[141] = 
#     dict[142] = 
#     dict[143] = 
#     dict[144] = 
#     dict[145] = 
#     dict[146] = 
#     dict[147] = 
#     dict[148] = 
#     dict[149] = 
#     dict[150] = 
#     dict[151] = 
#     dict[152] = 
#     dict[153] = 
#     dict[154] = 
#     dict[155] = 
#     dict[156] = 
#     dict[157] = 
#     dict[158] = 
#     dict[159] = 
#     dict[160] = 
#     dict[161] = 
#     dict[162] = 
#     dict[163] = 
#     dict[164] = 
#     dict[165] = 
#     dict[166] = 
#     dict[167] =
#     dict[168] = 
#     dict[169] = 
#     dict[170] = 
#     dict[171] = 
#     dict[172] = 
#     dict[173] = 
#     dict[174] = 
#     dict[175] = 
#     dict[176] = 
#     dict[177] = 
#     dict[178] = 
#     dict[179] = 
#     dict[180] = 
#     dict[181] = 
#     dict[182] = 
#     dict[183] = 
#     dict[184] = 
#     dict[185] = 
#     dict[186] = 
#     dict[187] = 
#     dict[188] = 
#     dict[189] = 
#     dict[190] = 
#     dict[191] = 
#     dict[192] = 
#     dict[193] = 
#     dict[194] = 
#     dict[195] = 
#     dict[196] = 
#     dict[197] = 
#     dict[198] = 
#     dict[199] = 
#     dict[200] =
#     dict[201] = 
#     dict[202] = 
#     dict[203] = 
#     dict[204] = 
#     dict[205] = 
#     dict[206] =
#     dict[207] = 

#     return dict
# end