function sha1 (S, bin)
	local INFO = {
		_VERSION     = "sha-1.lua v1.1",
		_DESCRIPTION = "A Lua 5.3.* implementation of the Secure Hash Algorithm (SHA-1) (RFC 3174)"
	}
	local binary = bin or nil
	local format, rep, sub = string.format, string.rep, string.sub
	local lrotate, pack, unpack = bit32.lrotate, string.pack, string.unpack
	local l, e, k = #S*8, 0xffffffff
	local b = ((l-448)//512 + 1)*512 - (l-448)
	S = S.."\x80"..rep("\x00", (b>>3)-1)..pack(">LL", l>>32, l&e)
	local a = {
		H0 = 0x67452301, H1 = 0xEFCDAB89, H2 = 0x98BADCFE, H3 = 0x10325476, H4 = 0xC3D2E1F0,
		f = {
			function (B,C,D) return (B & C) | ((~B) & D) end,
			function (B,C,D) return (B ~ C) ~ D end,
			function (B,C,D) return (B & C) | (B & D) | (C & D) end,
			function (B,C,D) return (B ~ C) ~ D end
		},
		k = {
			0x5A827999, 0x6ED9EBA1, 0x8F1BBCDC, 0xCA62C1D6
		}
	}
	for k = 1, #S, 64 do
		local A, B, C, D, E, w = a.H0, a.H1, a.H2, a.H3, a.H4, {}
		local t, j, TEMP
		S:sub(k, k + 63):gsub("....", function (h) w[#w+1] = unpack(">L", h) end)
		for t = 17, 80 do
			w[t] = lrotate((w[t-3] ~ w[t-8] ~ w[t-14] ~ w[t-16]), 1)
		end
		for t = 1, 80 do
			j = (t-1)//20+1
			TEMP = lrotate(A, 5) + a.f[j](B, C, D) + E + w[t] + a.k[j]
			E, D, C, B, A = D&e, C&e, lrotate(B, 30)&e, A&e, TEMP&e
		end
		a.H0, a.H1, a.H2, a.H3, a.H4 = (a.H0 + A)&e, (a.H1 + B)&e, (a.H2 + C)&e, (a.H3 + D)&e, (a.H4 + E)&e
	end
	if (binary == nil) then
		return format("%08x%08x%08x%08x%08x", a.H0, a.H1, a.H2, a.H3, a.H4)
	else
		return pack("LLLLL", a.H0, a.H1, a.H2, a.H3, a.H4)
	end
end
