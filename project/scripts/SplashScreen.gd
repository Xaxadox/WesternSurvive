extends Control

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const SAVE_PATH: String = "F:/WesternSurvive/cache/progress.json"

const TIPS: Array[String] = [
	"Atenção para onde olha: suas armas base disparam na direção do seu olhar.",
	"Mitos dizem que um Pistoleiro na Cidade Fantasma transforma um revólver comum em ouro ao atingir nível máximo.",
	"No multiplayer local, a sobrevivência é um pacto. XP, armas e melhorias são compartilhadas.",
	"Toda arma atinge seu ápice no nível 5, ganhando seu bônus máximo. Escolha com sabedoria.",
	"As armas secretas fazem o trabalho sujo por você usando mira automática no inimigo mais próximo.",
	"Sobreviva aos 4 cenários iniciais para descobrir o que os trilhos do eclipse escondem..."
]

const TIPS_EN: Array[String] = [
	"Watch your aim: player 1 fires base weapons toward the mouse pointer.",
	"Legends say a Gunslinger in Ghost Town can turn a plain revolver into gold at max level.",
	"In local multiplayer, survival is a pact. XP, weapons and upgrades are shared.",
	"Every weapon peaks at level 5 and gains its max bonus. Choose wisely.",
	"Secret weapons do the dirty work for you by auto-aiming at the nearest enemy.",
	"Survive the 4 starting stages to discover what the eclipse rails are hiding..."
]

@onready var tip_label: Label = $TipLabel
@onready var progress_bar: ProgressBar = $ProgressBar

var _progress: Array[float] = [0.0]
var _loading_started: bool = false

func _ready() -> void:
	randomize()

	# Mostra uma dica diferente a cada abertura da splash screen.
	tip_label.text = str(_tips_for_language().pick_random())
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0

	if DisplayServer.get_name() == "headless":
		set_process(false)
		call_deferred("_change_to_main_scene_file")
		return

	# Inicia o carregamento assíncrono da cena principal.
	var error_code: Error = ResourceLoader.load_threaded_request(MAIN_SCENE_PATH, "PackedScene")
	if error_code != OK:
		push_error("Falha ao iniciar carregamento da cena principal: %s" % MAIN_SCENE_PATH)
		set_process(false)
		return

	_loading_started = true
	set_process(true)

func _process(_delta: float) -> void:
	if not _loading_started:
		return

	# A Godot preenche _progress[0] com um valor entre 0.0 e 1.0.
	var status: int = ResourceLoader.load_threaded_get_status(MAIN_SCENE_PATH, _progress)
	progress_bar.value = clampf(_progress[0] * 100.0, 0.0, 100.0)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			# O carregamento terminou; recupera o PackedScene e troca a cena.
			set_process(false)
			progress_bar.value = 100.0
			var packed_scene: PackedScene = ResourceLoader.load_threaded_get(MAIN_SCENE_PATH) as PackedScene
			if packed_scene == null:
				push_error("A cena carregada nao e um PackedScene valido: %s" % MAIN_SCENE_PATH)
				return
			get_tree().change_scene_to_packed(packed_scene)
		ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			push_error("Falha ao carregar a cena principal em segundo plano: %s" % MAIN_SCENE_PATH)
			_change_to_main_scene_file()
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			set_process(false)
			push_error("Recurso invalido para carregamento: %s" % MAIN_SCENE_PATH)
			_change_to_main_scene_file()

func _change_to_main_scene_file() -> void:
	progress_bar.value = 100.0
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _tips_for_language() -> Array[String]:
	return TIPS_EN if _saved_language() == "en" else TIPS

func _saved_language() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return "pt"

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return "pt"

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return "pt"

	var settings = parsed.get("settings", {})
	if typeof(settings) != TYPE_DICTIONARY:
		return "pt"

	return "en" if str(settings.get("language", "pt")) == "en" else "pt"
