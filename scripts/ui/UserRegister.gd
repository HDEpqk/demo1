extends Control



onready var name_line_edit:LineEdit=$BK/NameLineEdit
onready var pwd_line_edit:LineEdit=$BK/PwdLineEdit

onready var error_label:Label=$BK/ErrorLabel
onready var popup_dialog=$PopupDialog
onready var popup_dialog_label=$PopupDialog/Label
onready var popup_dialog_icon=$PopupDialog/Icon
var nick_name

# Called when the node enters the scene tree for the first time.
func _ready():
	#密码相关暂时不用
	$BK/PwdLabel.visible=false
	pwd_line_edit.visible=false
	
	
	error_label.visible=false
	error_label.self_modulate=Color.red
	#如果玩家有资格上榜,就打开注册面板，暂停游戏场景其他物体
	
	#绑定http相关事件
	EventBus.connect("http_create_user_completed",self,"_on_http_create_user_completed")
	EventBus.connect("http_read_user_id_by_name_completed",self,"_on_http_read_user_id_by_name_completed")
	EventBus.connect("network_error",self,"_on_network_error")

func _on_UserRegister_visibility_changed():
	get_tree().paused=self.visible


func _on_ConfirmButton_pressed():
	nick_name=name_line_edit.get_text()
	#var pwd=pwd_line_edit.get_text()
	#判断name_line_edit中的值是否合法和是否为空
	if nick_name.empty() or nick_name.find(" ") != -1 or nick_name.length()>32:
		error_label.set_text("昵称不能为空、不能有空格、长度不超过16位")
		error_label.visible=true
		DebugUtils.log("保存昵称失败")
		return
	#判断pwd_line_edit中的值是否合法和是否为空
#	elif pwd.empty() or pwd.find(" ") != -1 or pwd.length()>16:
#		error_label.set_text("密码不能为空、不能有空格、长度不超过16个字符")
#		error_label.visible=true
#		DebugUtils.log("保存密码失败")
#		return
	#判断数据库能否成功创建用户
	DataMgr.create_user(nick_name)

	

func _on_http_create_user_completed(result):
	if !result:
		error_label.set_text("昵称已存在")
		error_label.visible=true
		DebugUtils.log("保存昵称失败")
		return
	error_label.visible=false
	self.visible=false
	
	#将line_edit中的值存到本地
	DataMgr.set_setting("user","nick_name",nick_name)
	DataMgr.read_user_id_by_name(nick_name)
	
func _on_http_read_user_id_by_name_completed(result):
	var uid=result
	DataMgr.set_setting("user","user_id",uid)
	DebugUtils.log("成功保存用户id")
	popup_dialog_icon.set_visible(false)
	popup_dialog_label.self_modulate=Color("#19CAAD")
	popup_dialog_label.text="成功保存用户"
	popup_dialog.popup()

func _on_network_error(error_msg):
	popup_dialog_icon.set_visible(true)
	popup_dialog_label.self_modulate=Color("#F4606C")
	popup_dialog_label.text=error_msg
	popup_dialog.popup()
	
	
func _on_CancelButton_pressed():
	self.visible=false
	#SceneMgr.return_to_previous()
