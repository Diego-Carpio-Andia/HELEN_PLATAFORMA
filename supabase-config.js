/* =====================================================================
 *  Configuración de conexión a Supabase  ·  Plataforma Helen
 *  Este archivo lo usan tanto la web pública (index.html) como el
 *  panel administrativo (admin.html).
 *
 *  La "publishable key" es segura de exponer en el navegador:
 *  el acceso real está protegido por las políticas RLS de la base de datos
 *  (lectura pública, escritura solo para la administradora autenticada).
 * ===================================================================== */

const SUPABASE_URL = 'https://auedyjagriwtaqodobbd.supabase.co';
const SUPABASE_KEY = 'sb_publishable_eM31cLFycqeWX3bEJ2yv0w_IrgsA290';

// Número de WhatsApp de Helen (sin "+", formato internacional)
const WHATSAPP = '51947720840';

// Crea el cliente global de Supabase (requiere cargar antes el script de @supabase/supabase-js)
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
