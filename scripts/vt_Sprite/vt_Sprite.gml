// Feather ignore all
/** @desc 
	Cambia el sprite de una instancia
*/
/// @param {id.instance,asset.GMObject} instance     instancia a usar (puede ser un objeto)
/// @param {Asset.GMSprite}             spriteIndex  
/// @param {real}                       imageIndex   
/// @param {real}                       imageSpeed   
/// @param {real,array<real>}           [din]        =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>}           [dout]       =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaSprite(_ins, _sprite, _imgIndex=0, _imgSpeed=0, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	is = instanceof(self);
	
	/// @ignore objetivo
	target = _ins;
	/// @ignore sprite a usar
	sprite = _sprite;
	/// @ignore image index
	imgIndex = _imgIndex;
	/// @ignore imagen speed
	imgSpeed = _imgSpeed;
	
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _this = self;
			with (target) {
				if (_this.sprite != undefined) sprite_index = _this.sprite;
				
				image_index = _this.imgIndex;
				image_speed = _this.imgSpeed;
			}
			// Se completo.
			ready = true;
			return false;
		}
		
		return (out() );
	}
	
	/// @ignore
	static start = function()
	{
		// Buscar instancia en las variables.
		if (is_string(target) ) {
			var _ins = vt_vars_search(target);
			if (_ins != undefined) target = _ins;
		}

		started = true;
	}	
}

/** @desc
	Cambia el sprite de una instancia
*/
/// @param {Id.instance|Asset.GMObject} instance     instancia a usar (puede ser un objeto)
/// @param {Asset.GMSprite}             spriteIndex
/// @param {real}                       imageIndex
/// @param {real}                       imageSpeed
/// @param {real|array<real>}           [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>}           [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function vuelta_sprite(_ins, _sprite, _imgIndex=0, _imgSpeed=0, _in=0, _out=0)
{
	var _spr = new VueltaSprite(_ins, _sprite, _imgIndex, _imgSpeed, _in, _out);
	return (_spr);
}
