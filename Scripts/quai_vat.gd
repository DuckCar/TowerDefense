extends PathFollow2D

signal toi_dich(quai)
signal da_chet(quai)

@export var toc_do : float = 100.0
@export var mau_toi_da : int = 50
@export var sat_thuong_len_nha : int = 1
@export var do_lech_lan : float = 12.0        # quái đi lệch khỏi tim đường tối đa bao nhiêu px
@export var anh_goc_nhin_phai : bool = true   # ảnh quái vẽ nhìn sang PHẢI thì để bật

var mau_hien_tai : int
var dang_bi_choang : bool = false
var he_so_toc_do : float = 1.0                # 1.0 bình thường, 0.5 bị chậm 50%

var _lech_hien_tai : float
var _lech_muc_tieu : float
var _huong_ngang : int = 1                    # 1 = đang đi sang phải, -1 = sang trái
var _anim_hien_tai : String = ""
var _scale_x_goc : float = 1.0
var _hoat_hinh : AnimatedSprite2D = null

@onready var duong : Path2D = get_parent()
@onready var hitbox : Node2D = $Hitbox
@onready var co_the : Node2D = $Hitbox/Co_The

func _ready():
	rotates = false
	loop = false
	progress = 0.0
	mau_hien_tai = mau_toi_da

	_scale_x_goc = absf(co_the.scale.x)

	# Tìm AnimatedSprite2D (có thể chính Co_The, hoặc nằm trong Co_The)
	if co_the is AnimatedSprite2D:
		_hoat_hinh = co_the
	else:
		var ds = co_the.find_children("*", "AnimatedSprite2D", true, false)
		if ds.size() > 0:
			_hoat_hinh = ds[0]

	# mỗi con có tốc độ khác nhau một chút
	toc_do *= randf_range(0.92, 1.08)

	# mỗi con đi một làn riêng
	_lech_hien_tai = randf_range(-do_lech_lan, do_lech_lan)
	_lech_muc_tieu = _lech_hien_tai

func _process(delta):
	if dang_bi_choang:
		return

	progress += toc_do * he_so_toc_do * delta

	# làn đi trôi nhẹ
	_lech_hien_tai = move_toward(_lech_hien_tai, _lech_muc_tieu, 6.0 * delta)
	if is_equal_approx(_lech_hien_tai, _lech_muc_tieu):
		_lech_muc_tieu = randf_range(-do_lech_lan, do_lech_lan)

	_cap_nhat_huong_va_lech()

	if progress_ratio >= 1.0:
		toi_dich.emit(self)
		queue_free()

# Hướng nhìn lấy từ ĐƯỜNG (tiếp tuyến), không lấy từ vị trí quái.
# Độ lệch làn đặt vuông góc với đường, áp lên Hitbox.
func _cap_nhat_huong_va_lech():
	var c = duong.curve
	var a = c.sample_baked(maxf(progress - 4.0, 0.0))
	var b = c.sample_baked(progress + 4.0)
	var h = (b - a).normalized()

	# lệch vuông góc với hướng đi (v_offset của PathFollow2D chỉ lệch theo trục Y khi tắt Rotates)
	var phap_tuyen = Vector2(-h.y, h.x)
	hitbox.position = phap_tuyen * _lech_hien_tai

	# đổi hướng nhìn: chỉ khi thật sự đi ngang
	if h.x > 0.4:
		_huong_ngang = 1
	elif h.x < -0.4:
		_huong_ngang = -1

	var dau = 1.0 if anh_goc_nhin_phai else -1.0
	co_the.scale.x = _scale_x_goc * _huong_ngang * dau

	# chọn animation
	var anim := "di_ngang"
	if absf(h.y) > absf(h.x):
		anim = "di_xuong" if h.y > 0 else "di_len"
	_phat_anim(anim)

func _phat_anim(ten: String):
	if ten == _anim_hien_tai:
		return
	_anim_hien_tai = ten
	if _hoat_hinh and _hoat_hinh.sprite_frames and _hoat_hinh.sprite_frames.has_animation(ten):
		_hoat_hinh.play(ten)

# --- CHUẨN BỊ CHO TRỤ BẮN ---
func nhan_sat_thuong(luong: int):
	mau_hien_tai -= luong
	if mau_hien_tai <= 0:
		da_chet.emit(self)
		queue_free()

func lam_cham(he_so: float, thoi_gian: float):
	he_so_toc_do = he_so
	await get_tree().create_timer(thoi_gian).timeout
	if is_instance_valid(self):
		he_so_toc_do = 1.0

func lam_choang(thoi_gian: float):
	dang_bi_choang = true
	await get_tree().create_timer(thoi_gian).timeout
	if is_instance_valid(self):
		dang_bi_choang = false
