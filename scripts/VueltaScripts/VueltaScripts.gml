/// "Vuelta" es un sistema basado en lo creado por FriendlyCosmonaut pero utilizando funciones modernas de gml.
/// Permite ejecutar "eventos" secuenciados uno tras el otro. Las Vueltas se deben de iniciar utilizando el metodo .start() o usando vuelta_start
/// @param {string}               vueltaName  Nombre de este VueltaManager
/// @param {array<Struct.Vuelta>} events      Array de eventos
/// @param {bool}                 [seconds]   =true usar segundos(true) o steps(false)
/// @param {real}                 [timeScale] =1 Dilatacion de tiempo
function vuelta(_name, _events, _useSeconds, _timeScale)
{
	return (new VueltaManager(_name, _events, _useSeconds, _timeScale) );
}

/// @desc Inicia una vuelta
/// @param {Struct.VueltaManager} vueltaManager
function vuelta_start(_vuelta)
{
	return (_vuelta.start() );
}

/// @desc Establece una variable global en el manager
/// @param {string} key
/// @param {string} value
function vuelta_set_variable(_key, _value)
{
	static v = new VueltaManager("",[]);
	v.setVariable(_key, _value);
}

/// @desc Obtiene una variable global en el manager
/// @param {string} key
function vuelta_get_variable(_key)
{
	static v = new VueltaManager("",[]);
	return (v.getVariable(_key) );
}

/// @desc Remueve una variable global en el manager
/// @param {string} key
function vuelta_remove_variable(_key)
{
	static v= new VueltaManager("",[]);
	return (v.removeVariable(_key) );
}


