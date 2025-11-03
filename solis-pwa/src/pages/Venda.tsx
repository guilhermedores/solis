import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useCarrinhoStore } from '../stores/carrinho.store'

export default function Venda() {
  const navigate = useNavigate()
  const [codigoBarras, setCodigoBarras] = useState('')
  const { itens, valorLiquido, quantidadeItens } = useCarrinhoStore()
  
  return (
    <div className="h-screen flex flex-col bg-gray-50 overflow-hidden">
      {/* Header - altura fixa */}
      <header className="bg-white shadow-md flex-shrink-0 z-10">
        <div className="px-4 py-3 sm:py-4">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Nova Venda</h1>
              <p className="text-sm text-gray-600">Terminal 1</p>
            </div>
            
            <button
              onClick={() => navigate('/dashboard')}
              className="px-3 py-2 sm:px-4 text-sm sm:text-base bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors"
            >
              Voltar
            </button>
          </div>
        </div>
      </header>
      
      {/* Content - ocupa altura restante */}
      <div className="flex-1 overflow-hidden">
        <div className="h-full grid grid-cols-1 lg:grid-cols-3 gap-0 lg:gap-4 p-2 sm:p-4">
          {/* Busca de Produtos e Lista - ocupa 2/3 em telas grandes */}
          <div className="lg:col-span-2 flex flex-col space-y-3 sm:space-y-4 h-full overflow-hidden">
            {/* Busca de Produtos - altura fixa */}
            <div className="bg-white rounded-lg shadow-md p-3 sm:p-4 flex-shrink-0">
              <input
                type="text"
                value={codigoBarras}
                onChange={(e) => setCodigoBarras(e.target.value)}
                placeholder="Digite o código de barras ou busque por nome"
                className="w-full px-3 sm:px-4 py-2 sm:py-3 text-base sm:text-lg border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                autoFocus
              />
            </div>
            
            {/* Lista de Itens - altura flexível com scroll */}
            <div className="bg-white rounded-lg shadow-md flex-1 flex flex-col overflow-hidden">
              <div className="p-3 sm:p-4 border-b flex-shrink-0">
                <h2 className="text-lg sm:text-xl font-bold text-gray-800">
                  Itens da Venda ({quantidadeItens()})
                </h2>
              </div>
              
              <div className="flex-1 overflow-y-auto scrollbar-hide divide-y">
                {itens.length === 0 ? (
                  <div className="h-full flex items-center justify-center p-8 text-center text-gray-400">
                    <div>
                      <p className="text-lg sm:text-xl">Nenhum item adicionado</p>
                      <p className="text-sm sm:text-base mt-2">Escaneie ou busque produtos para adicionar</p>
                    </div>
                  </div>
                ) : (
                  itens.map((item) => (
                    <div key={item.sequencia} className="p-3 sm:p-4 hover:bg-gray-50 transition-colors">
                      <div className="flex justify-between items-start gap-2">
                        <div className="flex-1 min-w-0">
                          <h3 className="font-semibold text-gray-900 text-sm sm:text-base truncate">
                            {item.nomeProduto}
                          </h3>
                          <p className="text-xs sm:text-sm text-gray-500">Cód: {item.codigoProduto}</p>
                        </div>
                        <button className="text-red-500 hover:text-red-700 transition-colors flex-shrink-0 p-1">
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                          </svg>
                        </button>
                      </div>
                      
                      <div className="mt-2 flex justify-between items-center">
                        <div className="flex items-center space-x-2 sm:space-x-4">
                          <span className="text-sm sm:text-base text-gray-600">
                            {item.quantidade}x R$ {item.precoUnitario.toFixed(2)}
                          </span>
                        </div>
                        <span className="text-base sm:text-lg font-bold text-gray-900">
                          R$ {item.valorTotal.toFixed(2)}
                        </span>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
          
          {/* Resumo e Pagamento - ocupa 1/3 em telas grandes */}
          <div className="flex flex-col space-y-3 sm:space-y-4 h-full overflow-y-auto lg:overflow-hidden">
            {/* Resumo */}
            <div className="bg-white rounded-lg shadow-md p-4 sm:p-6 flex-shrink-0">
              <h2 className="text-lg sm:text-xl font-bold text-gray-800 mb-3 sm:mb-4">Resumo</h2>
              
              <div className="space-y-2 sm:space-y-3">
                <div className="flex justify-between text-sm sm:text-base text-gray-600">
                  <span>Subtotal:</span>
                  <span>R$ {valorLiquido().toFixed(2)}</span>
                </div>
                <div className="flex justify-between text-sm sm:text-base text-gray-600">
                  <span>Desconto:</span>
                  <span>R$ 0,00</span>
                </div>
                <div className="border-t pt-2 sm:pt-3 flex justify-between text-xl sm:text-2xl font-bold text-gray-900">
                  <span>Total:</span>
                  <span className="text-green-600">R$ {valorLiquido().toFixed(2)}</span>
                </div>
              </div>
              
              <button
                disabled={itens.length === 0}
                className="w-full mt-4 sm:mt-6 bg-green-600 text-white py-3 sm:py-4 rounded-lg font-bold text-base sm:text-lg hover:bg-green-700 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed shadow-lg"
              >
                Finalizar Venda (F2)
              </button>
            </div>
            
            {/* Atalhos */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 sm:p-4 flex-shrink-0">
              <h3 className="font-semibold text-blue-900 mb-2 text-sm sm:text-base">Atalhos</h3>
              <ul className="text-xs sm:text-sm text-blue-800 space-y-1">
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
