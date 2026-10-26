extends PathFollow2D

# Khai báo biến tốc độ chạy của quái vật
var toc_do : float = 150.0 

# Hàm _process sẽ tự động chạy liên tục 60 khung hình/giây
func _process(delta):
	# Thuộc tính 'progress' giúp quái vật tự tiến lên phía trước dọc theo sợi dây
	progress += toc_do * delta
