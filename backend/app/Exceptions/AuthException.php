<?php

namespace App\Exceptions;

use Exception;

class AuthException extends Exception
{
    // You can customize the exception message and status code
    protected $message;
    protected $code;

    public function __construct($message = "Authentication error", $code = 401)
    {
        parent::__construct($message, $code);
        $this->message = $message;
        $this->code = $code;
    }

    public function render($request)
    {
        return response()->json(['error' => $this->message], $this->code);
    }
}
