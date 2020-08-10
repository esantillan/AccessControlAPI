<?php
declare(strict_types=1);
/**
 * Codifica caracteres especiales
 */
function sanitize_string (String $text): String
{
   $text = trim($text);
   return filter_var($text, FILTER_SANITIZE_STRING, [FILTER_FLAG_ENCODE_LOW, FILTER_FLAG_ENCODE_HIGH, FILTER_FLAG_ENCODE_AMP]);
}

?>