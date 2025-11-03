import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useCarrinhoStore } from '../stores/carrinho.store'

export default function Venda() {
  const navigate = useNavigate()
  const [codigoBarras, setCodigoBarras] = useState('')
  const { itens, valorLiquido, quantidadeItens } = useCarrinhoStore()
  
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Nova Venda</h1>
              <p className="text-gray-600">Terminal 1</p>
            </div>
            
            <button
              onClick={() => navigate('/dashboard')}
              className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300"
            >
              Voltar
            </button>
          </div>
        </div>
      </header>
      
      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Busca de Produtos */}
          <div className="lg:col-span-2 space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <input
                type="text"
                value={codigoBarras}
                onChange={(e) => setCodigoBarras(e.target.value)}
                placeholder="Digite o código de barras ou busque por nome"
                className="w-full px-4 py-3 text-lg border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                autoFocus
              />
            </div>
            
            {/* Lista de Itens */}
            <div className="bg-white rounded-lg shadow">
              <div className="p-6 border-b">
                <h2 className="text-xl font-bold text-gray-800">
                  Itens da Venda ({quantidadeItens()})
                </h2>
              </div>
              
              <div className="divide-y">
                {itens.length === 0 ? (
                  <div className="p-12 text-center text-gray-400">
                    <p className="text-lg">Nenhum item adicionado</p>
                    <p className="text-sm">Escaneie ou busque produtos para adicionar</p>
                  </div>
                ) : (
                  itens.map((item) => (
                    <div key={item.sequencia} className="p-4 hover:bg-gray-50">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <h3 className="font-semibold text-gray-900">{item.nomeProduto}</h3>
                          <p className="text-sm text-gray-500">Cód: {item.codigoProduto}</p>
                        </div>
                        <button className="text-red-500 hover:text-red-700 ml-4">
                          ✕
                        </button>
                      </div>
                      
                      <div className="mt-2 flex justify-between items-center">
                        <div className="flex items-center space-x-4">
                          <span className="text-gray-600">
                            {item.quantidade}x R$ {item.precoUnitario.toFixed(2)}
                          </span>
                        </div>
                        <span className="text-lg font-bold text-gray-900">
                          R$ {item.valorTotal.toFixed(2)}
                        </span>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
          
          {/* Resumo e Pagamento */}
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-bold text-gray-800 mb-4">Resumo</h2>
              
              <div className="space-y-3">
                <div className="flex justify-between text-gray-600">
                  <span>Subtotal:</span>
                  <span>R$ {valorLiquido().toFixed(2)}</span>
                </div>
                <div className="flex justify-between text-gray-600">
                  <span>Desconto:</span>
                  <span>R$ 0,00</span>
                </div>
                <div className="border-t pt-3 flex justify-between text-2xl font-bold text-gray-900">
                  <span>Total:</span>
                  <span className="text-green-600">R$ {valorLiquido().toFixed(2)}</span>
                </div>
              </div>
              
              <button
                disabled={itens.length === 0}
                className="w-full mt-6 bg-green-600 text-white py-4 rounded-lg font-bold text-lg hover:bg-green-700 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed"
              >
                Finalizar Venda (F2)
              </button>
            </div>
            
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h3 className="font-semibold text-blue-900 mb-2">Atalhos</h3>
              <ul className="text-sm text-blue-800 space-y-1">
                <li>F2 - Finalizar Venda</li>
                <li>F4 - Buscar Produto</li>
                <li>F8 - Cancelar Venda</li>
                <li>ESC - Voltar</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
