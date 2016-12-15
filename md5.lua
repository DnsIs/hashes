function md5 (S, bin)
	local INFO = {
		_VERSION     = "md5.lua 1.1",
		_DESCRIPTION = "MD5 computation for Lua (5.3.*)"
	}

	local binary = bin or nil
	local format, char, rep, sub = string.format, string.char, string.rep, string.sub
	local floor, abs, sin, lrotate, pack, unpack = math.floor, math.abs, math.sin, bit32.lrotate, string.pack, string.unpack
	local l, e, k = #S*8, 0xffffffff
	local b = ((l-448)//512 + 1)*512 - (l-448)
	S = S.."\x80"..rep("\x00", (b>>3)-1)..pack("LL", l&e, l>>32)
	local a = {
		A = 0x67452301, B = 0xefcdab89, C = 0x98badcfe, D = 0x10325476,
		FGHI = {
			function (X,Y,Z) return (X & Y) | ((~X) & Z) end,
			function (X,Y,Z) return (X & Z) | (Y & (~Z)) end,
			function (X,Y,Z) return (X ~ Y) ~ Z end,
			function (X,Y,Z) return Y ~ (X | (~Z)) end
		},
		r = {
			{"A", "B", "C", "D",  1,  7}, {"D", "A", "B", "C",  2, 12}, {"C", "D", "A", "B",  3, 17}, {"B", "C", "D", "A",  4, 22},
			{"A", "B", "C", "D",  5,  7}, {"D", "A", "B", "C",  6, 12}, {"C", "D", "A", "B",  7, 17}, {"B", "C", "D", "A",  8, 22},
			{"A", "B", "C", "D",  9,  7}, {"D", "A", "B", "C", 10, 12}, {"C", "D", "A", "B", 11, 17}, {"B", "C", "D", "A", 12, 22},
			{"A", "B", "C", "D", 13,  7}, {"D", "A", "B", "C", 14, 12}, {"C", "D", "A", "B", 15, 17}, {"B", "C", "D", "A", 16, 22},
			
			{"A", "B", "C", "D",  2,  5}, {"D", "A", "B", "C",  7,  9}, {"C", "D", "A", "B", 12, 14}, {"B", "C", "D", "A",  1, 20},
			{"A", "B", "C", "D",  6,  5}, {"D", "A", "B", "C", 11,  9}, {"C", "D", "A", "B", 16, 14}, {"B", "C", "D", "A",  5, 20},
			{"A", "B", "C", "D", 10,  5}, {"D", "A", "B", "C", 15,  9}, {"C", "D", "A", "B",  4, 14}, {"B", "C", "D", "A",  9, 20},
			{"A", "B", "C", "D", 14,  5}, {"D", "A", "B", "C",  3,  9}, {"C", "D", "A", "B",  8, 14}, {"B", "C", "D", "A", 13, 20},
			
			{"A", "B", "C", "D",  6,  4}, {"D", "A", "B", "C",  9, 11}, {"C", "D", "A", "B", 12, 16}, {"B", "C", "D", "A", 15, 23},
			{"A", "B", "C", "D",  2,  4}, {"D", "A", "B", "C",  5, 11}, {"C", "D", "A", "B",  8, 16}, {"B", "C", "D", "A", 11, 23},
			{"A", "B", "C", "D", 14,  4}, {"D", "A", "B", "C",  1, 11}, {"C", "D", "A", "B",  4, 16}, {"B", "C", "D", "A",  7, 23},
			{"A", "B", "C", "D", 10,  4}, {"D", "A", "B", "C", 13, 11}, {"C", "D", "A", "B", 16, 16}, {"B", "C", "D", "A",  3, 23},
			
			{"A", "B", "C", "D",  1,  6}, {"D", "A", "B", "C",  8, 10}, {"C", "D", "A", "B", 15, 15}, {"B", "C", "D", "A",  6, 21},
			{"A", "B", "C", "D", 13,  6}, {"D", "A", "B", "C",  4, 10}, {"C", "D", "A", "B", 11, 15}, {"B", "C", "D", "A",  2, 21},
			{"A", "B", "C", "D",  9,  6}, {"D", "A", "B", "C", 16, 10}, {"C", "D", "A", "B",  7, 15}, {"B", "C", "D", "A", 14, 21},
			{"A", "B", "C", "D",  5,  6}, {"D", "A", "B", "C", 12, 10}, {"C", "D", "A", "B",  3, 15}, {"B", "C", "D", "A", 10, 21}
		}
	}
	for i = 1, 64 do
		a.r[i][7] = floor((1 << 32) * abs(sin(i)))
	end
	for k = 1, #S, 64 do
		local AA, BB, CC, DD = a.A, a.B, a.C, a.D
		local s_, c, i = sub(S, k, k+63), {}
		s_:gsub ("....", function (i) c[#c+1] = unpack("L", i) end)
		for i = 1, 64 do
			local el, f = a.r[i], a.FGHI[(i-1>>4)+1]
			local A, B, C, D, X, T, s = a[el[1]], a[el[2]], a[el[3]], a[el[4]], c[el[5]], el[7], el[6]
			a[el[1]] = B + lrotate((A + f(B, C, D) + X + T),  s)
		end
		a.A, a.B, a.C, a.D = AA+a.A, BB+a.B, CC+a.C, DD+a.D
	end
	bin = "" .. pack("<LLLL", a.A&e, a.B&e, a.C&e, a.D&e)
	if (binary ~= nil) then
		return bin
	else
		return format("%016x%016x", unpack(">J", bin:sub(1, 8)), unpack(">J", bin:sub(9, 16)))
	end
end
