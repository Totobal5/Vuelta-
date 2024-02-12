// Feather ignore all
#macro __VUELTA_VERSION			"1.3"		// Version de Vuelta!
#macro __VUELTA_DEBUG			false		// Permite mostrar mensajes
#macro __VUELTA_DEBUG_DELAY		false		// Muestra el delay in/out de las vueltas

show_debug_message($"Vuelta! v{__VUELTA_VERSION} te da la bienvenida");

/// @ignore
/// @desc Padres de todos
function Vuelta() constructor 
{
	// Variables que todos los elementos vuelta pueden usar y modificar
	static vars = {}
	
	/// @ignore
	is = instanceof(self);
	/// @ignore
	name = "";
	/// @ignore
	debugMessage = "";

	/// @ignore
	ready   = false;
	/// @ignore
	started = false;
	
	/// @ignore
	timeScale = 1;
	/// @ignore
	manager   = weak_ref_create(vars);

	/// @ignore
	/// @desc Funcion a ejecutar cuando inicia el Vuelta!
	fnStart = function() {}
	
	/// @ignore
	/// @desc Funcion a ejecutar cuando termina el Vuelta!
	fnEnd = function() {}
	/// @ignore
	fnEndReady = false;
	
	/// @ignore
	/// @desc Funcion al cambiar de evento
	fnChange = function() {}

	#region METHODS

	/// @ignore
	/// @return {bool}
	static in  = function() 
	{
		return true;
	}
	
	/// @ignore
	/// @return {bool}
	static out = function() 
	{
		return true;
	}
	
	/// @ignore
	/// @return {bool}
	static event = function() 
	{
		return ready; 
	}
	
	/// @ignore
	/// @desc Cambia la escala de tiempo
	/// @param {real} [timeScale]=1
	static setTimeScale = function(_timeScale=1)
	{
		timeScale = _timeScale;
		return self;
	}
	
	/// @ignore
	/// @desc Cambia el nombre de este Vuelta!.
	/// @param {string} name Nombre a usar.
	static setName = function(_name)
	{
		name = _name;
		return self;
	}
	
	/// @ignore
	/// @param {Struct.VueltaManager} Manager
	static setManager = function(_vtm) 
	{
		manager = weak_ref_create(_vtm);
		return self;
	}
	
	/// @desc Devuelve el VueltaManager que lo maneja.
	/// @return {Struct.VueltaManager}
	static getManager = function()
	{
		return (manager.ref);
	}
	
	/// @ignore
	/// @param {function} endFunction
	static setFnEnd = function(_fn) 
	{
		fnEnd = _fn;
		return self;
	}
	
	/// @ignore
	/// @param {function} startFunction
	static setFnStart = function(_fn)
	{
		fnStart = _fn;
		return self;
	}
	
	/// @ignore
	/// @param {function} changeFunction
	static setFnChange = function(_fn)
	{
		fnChange = _fn;
		return self;
	}

	/// @desc Devolver si esta listo.
	/// @return {bool}
	static isReady = function() 
	{
		return (ready);
	}
	
	#region --MISQ
	/// @ignore
	/// @desc Mensaje a mostrar.
	/// @param {string} message Mensaje a mostrar
	static setDebugMessage = function(_msg) 
	{
		debugMessage = _msg;
		return self;
	}

	#endregion

	#endregion
}

// EJECUTAR PARA QUE LAS VARIABLES ESTATICAS SIEMPREN ESTEN LISTAS.
Vuelta();