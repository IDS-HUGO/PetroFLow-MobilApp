class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

/// Traduce errores técnicos del sistema y de la base de datos (Supabase/JWT/SQL)
/// a un lenguaje amigable en español para el usuario final.
String getReadableError(Object error) {
  if (error is ApiException) {
    final msg = error.message.toLowerCase();
    
    // Errores relacionados con JWT y Sesión
    if (msg.contains('jwt') || 
        msg.contains('token') || 
        msg.contains('claim') || 
        msg.contains('session') ||
        msg.contains('expired') ||
        msg.contains('refresh_token_not_found') ||
        msg.contains('invalid signature')) {
      return 'Su sesión ha expirado o no es válida. Por favor, ingrese de nuevo.';
    }
    
    // Errores de credenciales
    if (msg.contains('invalid login credentials') || 
        msg.contains('invalid credentials') || 
        msg.contains('password is not valid') ||
        msg.contains('email_not_confirmed')) {
      return 'El correo o la contraseña son incorrectos.';
    }
    
    // Errores de registro
    if (msg.contains('user already exists') || 
        msg.contains('already registered') || 
        msg.contains('email already in use')) {
      return 'Este correo electrónico ya está registrado en el sistema.';
    }
    
    // Errores de longitud/seguridad
    if (msg.contains('password should be at least') || msg.contains('weak password')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    
    // Errores de Base de Datos y Scripts
    if (msg.contains('relation') && msg.contains('does not exist')) {
      return 'Error de configuración: Faltan tablas en el servidor. Por favor, inicialice la base de datos.';
    }
    
    if (msg.contains('violates foreign key constraint') || msg.contains('parent key')) {
      return 'No se puede realizar la operación debido a una restricción de datos en el sistema.';
    }
    
    // Errores de Red y Conectividad
    if (msg.contains('failed host lookup') || 
        msg.contains('socket') || 
        msg.contains('connection failed') || 
        msg.contains('network_error') ||
        msg.contains('connection refused') ||
        msg.contains('httpclientexception')) {
      return 'No se pudo conectar al servidor. Verifique su conexión a Internet.';
    }
    
    return error.message;
  }

  final errStr = error.toString().toLowerCase();
  
  // Revisar si la cadena del error contiene patrones técnicos comunes
  if (errStr.contains('jwt') || errStr.contains('token') || errStr.contains('expired')) {
    return 'Su sesión ha expirado o no es válida. Por favor, ingrese de nuevo.';
  }
  if (errStr.contains('socketexception') || 
      errStr.contains('failed host lookup') || 
      errStr.contains('connection refused') ||
      errStr.contains('network') ||
      errStr.contains('httpclientexception')) {
    return 'Error de red: No se pudo conectar al servidor. Verifique su conexión a Internet.';
  }
  if (errStr.contains('relation') && errStr.contains('does not exist')) {
    return 'Error de configuración: La base de datos no está inicializada correctamente.';
  }
  if (errStr.contains('invalid credentials') || errStr.contains('invalid login credentials')) {
    return 'El correo o la contraseña son incorrectos.';
  }

  // Quitar prefijos genéricos de excepciones
  String readable = error.toString();
  if (readable.startsWith('Exception: ')) {
    readable = readable.substring(11);
  } else if (readable.startsWith('StateError: ')) {
    readable = readable.substring(12);
  }
  
  return readable;
}
