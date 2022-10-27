local audio = {
	enemyWarp = love.audio.newSource("assets/sound/EnemyWarpV1.ogg", "static"),
	music = love.audio.newSource("assets/sound/Magna_Beta_1.ogg", "stream"),
	enemySpawn = love.audio.newSource("assets/sound/EnemySpawnV1.ogg", "static"),
	enemyDeath = love.audio.newSource("assets/sound/EnemyDeathv1.ogg", "static"),
}

function audio:toggleMute()
	self.mute = not self.mute
	if self.mute then
		love.audio.setVolume(0)
	else
		love.audio.setVolume(.75)
	end
end

audio.music:setVolume(.5)
love.audio.setVolume(.75)

return audio
