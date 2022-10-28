local audio = {
	enemyWarp = love.audio.newSource("assets/sound/EnemyWarpV1.ogg", "static"),
	music = love.audio.newSource("assets/sound/Magna_Beta_1.ogg", "stream"),
	enemySpawn = love.audio.newSource("assets/sound/EnemySpawnV1.ogg", "static"),
	enemyDeath = love.audio.newSource("assets/sound/EnemyDeathV1.ogg", "static"),
	-- Sound Effect from <a href="https://pixabay.com/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=6409">Pixabay</a>
	magnaDeath = love.audio.newSource("assets/sound/MagnaDeath.ogg", "static"),
	-- Sound Effect by <a href="https://pixabay.com/users/blendertimer-9538909/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=13847">BlenderTimer</a> from <a href="https://pixabay.com/sound-effects//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=13847">Pixabay</a>
	crystalCrack = love.audio.newSource("assets/sound/CrystalBreak.ogg", "stream"),
}

local audioRng = love.math.newRandomGenerator()

audio.music:setVolume(.5)
audio.magnaDeath:setVolume(.5)
love.audio.setVolume(.75)

function audio:toggleMute()
	self.mute = not self.mute
	if self.mute then
		love.audio.setVolume(0)
	else
		love.audio.setVolume(.75)
	end
end

function audio:playerEnemyWarp()
	love.audio.play(self.enemyWarp)
end

function audio:playEnemySpawn()
	love.audio.play(self.enemySpawn)
end

function audio:playEnemyDeath()
	love.audio.play(self.enemyDeath)
end

function audio:playMagnaDeath()
	love.audio.play(self.magnaDeath)
end

function audio:playCrystalCrack()
	if self.crystalCrack:isPlaying() then
		self.crystalCrack:stop()
	end
	self.crystalCrack:setPitch(audioRng:random(9, 18) / 17)
	love.audio.play(self.crystalCrack)
end

return audio
