<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;

class EmailController extends Controller
{
    public function index()
    {
        return Inertia::render('EmailGenerator');
    }

    public function generate(Request $request)
    {
        $qtdTerminais = count($request->seriais);

        $linhasAcesso = "";
        foreach ($request->seriais as $i => $serial) {
            $tv = $request->teamviewers[$i] ?? "";
            $linhasAcesso .= "Serial: {$serial} - TeamViewer: {$tv}\n";
        }

        $titulo = "[Liberação de totem em {$request->implantacao}]"
                . "[VS Food][{$request->razao_social}]"
                . "[Pedido {$request->num_pedido}] "
                . "[{$qtdTerminais} Terminais]";

        $corpo = "Boa tarde!
Segue acesso ( IMPLANTAÇÃO EM {$request->implantacao} )

Cliente: {$request->razao_social}
Pedido Senior: {$request->num_pedido}
Vendedor: {$request->vendedor}
{$linhasAcesso}
Impressora: {$request->impressora}
";

        // Retornando JSON — sem mudar a URL
        return response()->json([
            'titulo' => $titulo,
            'corpo'  => $corpo,
        ]);
    }
}
