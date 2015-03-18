local hs2 = {}

function hs2.load(fname, places, name, score)
	local i

	--write new high score table if it doesn't exist yet
	if not love.filesystem.exists(fname) then
		towrite = ''
		for i = 1, places do
			towrite = towrite..name..'\t'..score
			if i < places then
				towrite = towrite..'\n'
			end
		end
		love.filesystem.write(fname, towrite)
	end

	--load high score table
	local hs = {fname = fname, pos = {}}
	for line in love.filesystem.lines(fname) do
		table.insert(hs.pos, {name = line:sub(1, line:find('\t') - 1), score = tonumber(line:sub(line:find('\t') + 1, #line))})
	end

	--**and now...the functions**
	--add high score to the table in the correct position
	function hs:add(name, score)
		for i = 1, #self.pos do
			if score > self.pos[i].score then
				table.insert(self.pos, i, {name = name, score = score})
				return i
			end
		end
		--for last-place scores
		table.insert(self.pos, {name = name, score = score})
		return #self.pos
	end

	--get name and score at position
	function hs:get(pos)
		if self.pos[pos] then
			return self.pos[pos].name, self.pos[pos].score
		else
			return nil
		end
	end

	--get length of high score table
	function hs:len()
		return #self.pos
	end

	--get filename of high score table
	function hs:filename()
		return self.fname
	end

	--save high score table
	function hs:save()
		local towrite = ''
		for i = 1, #self.pos do
			towrite = towrite..self.pos[i].name..'\t'..self.pos[i].score
			if i < #self.pos then
				towrite = towrite..'\n'
			end
		end
		love.filesystem.write(self.fname, towrite)
	end

	--iterator that returns scores and names
	function hs:cycle()
		local i = 0
		return function()
			i = i + 1
			if self.pos[i] then
				return i, self.pos[i].name, self.pos[i].score
			end
		end
	end

	return hs
end

return hs2