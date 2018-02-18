local json = require("pack.json")

local M = {}

M.enable_obfuscation = false -- if true then all data saved and loaded will be XOR obfuscated - FASTER
M.obfuscation_key = "pack" -- pick a unique obfuscation key, the longer the key for obfuscation the better

function M.set_obfuscation_key(key)
	M.obfuscation_key = key
end

function M.set_obfuscation_flag(flag)
	M.enable_obfuscation = flag
end

-- xor key based obfuscation - the input must be a string
function M.obfuscate(input, key, force_obfuscation)
	force_obfuscation = force_obfuscation or false
	if M.enable_obfuscation == false and not force_obfuscation then return input end
	key = key or M.obfuscation_key
	local output = ""
	local key_iterator = 1

	local input_length = #input
	local key_length = #key

	for i=1, input_length do
		local character = string.byte(input:sub(i,i))
		if key_iterator >= key_length then key_iterator = 1 end -- cycle
		local key_byte = string.byte(key:sub(key_iterator,key_iterator))
		output = output .. string.char(bit.bxor( character , key_byte))

		key_iterator = key_iterator + 1

	end
	return output
end

-- We don't want achievement data easy to edit
-- So we use simple zlib inflate/deflate to make it
-- just a little harder to edit
function M.decompress(buffer, key, force_obfuscation)
	force_obfuscation = force_obfuscation or false
	obfuscation_key = key or M.obfuscation_key
	if buffer == nil then return {} end
	buffer = zlib.inflate(buffer)
	buffer = M.obfuscate(buffer, obfuscation_key, force_obfuscation)
	buffer = json.decode(buffer)
	return buffer
end

function M.compress(buffer, key, force_obfuscation)
	force_obfuscation = force_obfuscation or false
	obfuscation_key = key or M.obfuscation_key
	buffer = json.encode(buffer)
	buffer = M.obfuscate(buffer, obfuscation_key, force_obfuscation)
	buffer = zlib.deflate(buffer)
	return buffer
end

return M