extends Node

const SQLite:Resource = preload("res://lib/gdsqlite.gdns")
const DB_PATH:String = "../../BDD/MusicArenaDB.db"

var db:SQLite


func _ready():
	db = SQLite.new()


# Identity check
func userExists(login:String, pw:String) -> int:
	if (!db.open_db(DB_PATH)):
		print("M:DB -> Error, can't open db")
		return -1
		
	var query:String = "SELECT Password, UserId FROM Users WHERE Pseudo = '"+login+"';"
	var result = db.fetch_array(query)
	
	db.close()
	
	# If no line was returned (no match found in db)
	if result.size()==0:
		return -1
	
	var storedPw:String = result[0]['Password']
	var userId:int = int(result[0]['UserId'])
	
	# User found and password hash matches
	if storedPw==pw:
		return userId
	# User exists, but wrong pw
	else:
		return -1


# Set the client as connected in DB
func connectionUpdate(userId:int) -> bool:
	if (!db.open_db(DB_PATH)):
		print("M:DB -> Error, can't open db")
		return false
	
	var query:String = "UPDATE Users SET Connected=1, LastConnection=datetime() WHERE UserId='"+str(userId)+"';"
	var result = db.query(query)
	
	db.close()
	return true


# Set the client as disconnected in DB
func disconnectionUpdate(userId:int) -> bool:
	if (!db.open_db(DB_PATH)):
		print("M:DB -> Error, can't open db")
		return false
	
	var query:String = "UPDATE Users SET Connected=0 WHERE UserId='"+str(userId)+"';"
	var result = db.query(query)
	
	db.close()
	return true


# Add a game played in Games
func newGameRegistered(playerNumber:int, duration:int) -> int:
	if (!db.open_db(DB_PATH)):
		print("M:DB -> Error, can't open db")
		return -1

	var query:String = "INSERT INTO Games (Date, PlayerNumber, Duration) VALUES (datetime(), '"+str(playerNumber)+"', "+str(duration)+");"
	var result = db.query(query)
	
	if !result:
		db.close()
		print("Insertion in DB failure")
		return -1
		
	query = "SELECT MAX(GameId) FROM Games;";
	result = db.fetch_array(query)[0]['MAX(GameId)']
	
	if result<1:
		db.close()
		print("Select in DB failure")
		return -1
	
	db.close()
	return result


### WIP/NOT USED
# For every clientwho played the game:
# 1) update VictorefeatNumber, TotalKills, TotalPlayingTime, Score
# 2) add a row in UserGames
func clientNewGameRegistered(userId:int, heroId:int, gameId:int, rank:int, victory:bool, totalKills:int, liveTime:int) -> bool:
	if (!db.open_db(DB_PATH)):
		print("M:DB -> Error, can't open db")
		return false
	
	var query:String = "INSERT INTO UserGames (UserId, GameId, HeroId, Rank, TotalKill, LiveTime)"
	query += "VALUES ("+str(userId)+", "+str(gameId)+", "+str(heroId)+", "+str(rank)
	query += ", "+str(totalKills)+", "+str(liveTime)+");"
	var result = db.query(query)
	
	if !result:
		db.close()
		return false
	
	query = "UPDATE Users SET TotalKills=TotalKills+"+str(totalKills)+", "
	query += "TotalPlayingTime=TotalPlayingTime+"+str(liveTime)+";"
	result = db.query(query)
	
	if !result:
		db.close()
		return false
	
	if victory:
		query = "UPDATE User SET VictoryNumber=VictoryNumber+1;"
	else:
		query = "UPDATE User SET DefeatNumber=DefeatNumber+1;"
	result = db.query(query)
	
	db.close()
	return result


# DEBUG
##Affichage des données de la BDD
func showData():
	if (!db.open_db(DB_PATH)):
		print("M:DB -> Error, can't open db")
		return false

	var query = "SELECT * FROM users;"
	var result = db.fetch_array(query)

	# Print rows
	if (result || result.size() > 0):
		for i in result:
			print(i)
	else:
		print("no data")

	db.close()
	return true


##---------------------database---------------------------
#
#
##Insertion dans la BDD
#func _db_insert(Mail,Password,TotalKills):
#	# Open database
#	if (!db.open_db("res://MusicArenaDB.db")):
#		print("Cannot open database.");
#		return;
#
#	# Insert new row
#	var query = "INSERT INTO users (Mail, Password, TotalKills) VALUES ('"+Mail+"', '"+Password+"', "+str(TotalKills)+");"
#	var result = db.query(query)
#	print(query)	
#	if (!result):
#		print("Cannot insert data!")
#	else:
#		print("Data inserted into table.")
#
#	# Close database
#	db.close();
#
##Update la position dans la BDD
#func _db_update_position(Mail,Password):
#	# Open database
#	if (!db.open_db("res://MusicArenaDB.db")):
#		print("Cannot open database.");
#		return;
#
#	# Update row
#	var query = "UPDATE users SET Password="+Password+" WHERE Mail = '"+Mail+"'"
#	var result = db.query(query)
#	print(query)	
#	if (!result):
#		print("Cannot update data!")
#	else:
#		print("Data updated.")
#
#	# Close database
#	db.close
#
##Delete data
#func _db_erase(Mail):
#	# Open database
#	if (!db.open_db("res://MusicArenaDB.db")):
#		print("Cannot open database.");
#		return;
#
#	var query = "DELETE FROM users WHERE id = "+Mail
#	var result = db.query(query)
#	print(query)	
#	if (!result):
#		print("Cannot delete data!")
#	else:
#		print("Data deleted.")
#
#	# Close database
#	db.close();
#
#
#
#func _db_get_last_id():
#	# Open database
#	if (!db.open_db("res://MusicArenaDB.db")):
#		print("Cannot open database.");
#		return;
#
#	var query = "SELECT MAX(id) FROM users;";
#	var result = db.fetch_array(query)[0]['MAX(id)']
#
#	# Close database
#	db.close();
#
#	return result
#
#func _db_get_name(id):
#	# Open database
#	if (!db.open_db("res://MusicArenaDB.db")):
#		print("Cannot open database.");
#		return;
#
#	var query = "SELECT Mail FROM users WHERE id = "+str(id);
#	var result = db.fetch_array(query)[0]['name']
#
#	# Close database
#	db.close();
#	return result
