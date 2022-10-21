local audio = {
	enemyWarp = love.audio.newSource("assets/sound/EnemyWarpV1.ogg", "static"),
	music = love.audio.newSource("assets/sound/Magna_Beta_1.ogg", "stream"),
	enemySpawn = love.audio.newSource("assets/sound/EnemySpawnV1.ogg", "static"),
	enemyDeath = love.audio.newSource("assets/sound/EnemyDeathv1.ogg", "static"),
}

audio.music:setVolume(.5)
love.audio.setVolume(.75)

return audio;
