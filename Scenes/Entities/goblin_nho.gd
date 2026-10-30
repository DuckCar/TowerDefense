extends PathFollow2D

# Khai báo biến tốc độ chạy của quái vật
var toc_do : float = 150.0

# Biến lưu trữ vị trí cũ để so sánh xem quái đang đi sang trái hay phải
var vi_tri_cu : Vector2

func _ready():
	# Ép tắt tính năng xoay lộn ngược của dây Path2D
	rotates = false
	
	# Lưu vị trí xuất phát ban đầu
	vi_tri_cu = global_position

func _process(delta):
	# 1. Thuộc tính 'progress' giúp quái vật tự tiến lên phía trước
	progress += toc_do * delta
	
	# 2. LOGIC LẬT MẶT QUÁI VẬT (Chỉ lật hình ảnh, không lật vùng va chạm vật lý)
	var vi_tri_moi = global_position
	
	# Tính toán độ chênh lệch trục X
	var khoang_cach_x = vi_tri_moi.x - vi_tri_cu.x
	
	# Sử dụng một sai số nhỏ (0.5 pixel) thay vì so sánh tuyệt đối để tránh giật mặt
	if khoang_cach_x < -0.5:
		# Đang đi sang trái -> Chỉ lật Node Co_the
		$Goblin_nho/Co_the.scale.x = -1
		
	elif khoang_cach_x > 0.5:
		# Đang đi sang phải -> Trả Node Co_the về bình thường
		$Goblin_nho/Co_the.scale.x = 1
		
	# Cập nhật lại vị trí cũ cho khung hình tiếp theo
	vi_tri_cu = vi_tri_moi
