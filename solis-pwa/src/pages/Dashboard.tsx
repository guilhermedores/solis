import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { healthService, caixaService } from '../services/agente-pdv.service'
import { useCaixaStore } from '../stores/caixa.store'
import { useNavigate } from 'react-router-dom'
import AbrirCaixaModal from '../components/AbrirCaixaModal'
import FecharCaixaModal from '../components/FecharCaixaModal'

export default function Dashboard() {
  const navigate = useNavigate()
  const { numeroTerminal } = useCaixaStore()
  const [modalAbrirCaixa, setModalAbrirCaixa] = useState(false)
  const [modalFecharCaixa, setModalFecharCaixa] = useState(false)
  
  // Health check do Agente PDV
  const { data: health, isLoading: loadingHealth, isError: healthError } = useQuery({
    queryKey: ['health'],
    queryFn: healthService.check,
    refetchInterval: 10000, // Refetch a cada 10s
    retry: 1, // Apenas 1 retry
    retryDelay: 1000, // 1 segundo entre retries
  })
  
  // Verificar caixa aberto
  const { data: caixa } = useQuery({
    queryKey: ['caixa-aberto', numeroTerminal],
    queryFn: () => caixaService.obterAberto(numeroTerminal),
    enabled: !!numeroTerminal,
  })
  
  return (
    <div className="h-screen flex flex-col bg-gray-50 overflow-hidden">
      {/* Header */}
      <header className="bg-white shadow flex-shrink-0">
        <div className="px-4 py-4 sm:py-6">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">Solis PDV</h1>
              <p className="text-sm sm:text-base text-gray-600">Terminal {numeroTerminal}</p>
            </div>
            
            {/* Status do Agente */}
            <div className="flex items-center space-x-2">
              <div className={`w-3 h-3 rounded-full ${
                loadingHealth ? 'bg-yellow-500' : 
                healthError ? 'bg-red-500' : 
                health?.status === 'healthy' ? 'bg-green-500' : 'bg-red-500'
              }`} />
              <span className="text-xs sm:text-sm text-gray-600">
                {loadingHealth ? 'Conectando...' : 
                 healthError ? 'Desconectado' :
                 health?.status === 'healthy' ? 'Conectado' : 'Erro'}
              </span>
            </div>
          </div>
        </div>
      </header>
      
      {/* Content */}
      <main className="flex-1 overflow-y-auto px-4 py-4 sm:py-8">
        {/* Alerta de Conexão */}
        {healthError && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-3 sm:px-4 py-2 sm:py-3 rounded-lg mb-4 sm:mb-6">
            <div className="flex items-center text-sm sm:text-base">
              <svg className="w-4 h-4 sm:w-5 sm:h-5 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
              </svg>
              <div>
                <strong className="font-bold">Agente PDV desconectado!</strong>
                <span className="block sm:inline sm:ml-2">Verifique se o serviço está rodando</span>
              </div>
            </div>
          </div>
        )}

        {/* Status do Caixa */}
        <div className="bg-white rounded-lg shadow p-4 sm:p-6 mb-6 sm:mb-8">
          <h2 className="text-lg sm:text-xl font-bold text-gray-800 mb-4">Status do Caixa</h2>
          
          {caixa ? (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-gray-600">Status:</span>
                <span className="px-3 py-1 bg-green-100 text-green-800 rounded-full font-semibold">
                  ABERTO
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-gray-600">Operador:</span>
                <span className="font-semibold">{caixa.operadorNome}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-gray-600">Abertura:</span>
                <span className="font-semibold">
                  {new Date(caixa.dataAbertura).toLocaleString('pt-BR')}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-gray-600">Valor Abertura:</span>
                <span className="font-semibold text-green-600">
                  R$ {caixa.valorAbertura.toFixed(2)}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-gray-600">Vendas:</span>
                <span className="font-semibold">{caixa.quantidadeVendas}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-gray-600">Total Vendido:</span>
                <span className="font-semibold text-blue-600">
                  R$ {caixa.totalVendas.toFixed(2)}
                </span>
              </div>
              
              <div className="pt-4 border-t">
                <button 
                  onClick={() => setModalFecharCaixa(true)}
                  disabled={healthError}
                  className="w-full bg-red-600 text-white px-6 py-2 rounded-lg hover:bg-red-700 disabled:bg-gray-400 disabled:cursor-not-allowed font-semibold"
                >
                  Fechar Caixa
                </button>
              </div>
            </div>
          ) : (
            <div className="text-center py-6 sm:py-8">
              <p className="text-sm sm:text-base text-gray-600 mb-4">Nenhum caixa aberto</p>
              <button 
                onClick={() => setModalAbrirCaixa(true)}
                disabled={healthError}
                className="bg-blue-600 text-white px-4 sm:px-6 py-2 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed text-sm sm:text-base transition-colors"
              >
                Abrir Caixa
              </button>
            </div>
          )}
        </div>
        
        {/* Ações */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
          <button
            onClick={() => navigate('/venda')}
            disabled={!caixa || healthError}
            className="bg-blue-600 text-white p-6 sm:p-8 rounded-lg hover:bg-blue-700 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed shadow-lg"
          >
            <h3 className="text-xl sm:text-2xl font-bold mb-2">Nova Venda</h3>
            <p className="text-blue-100 text-sm sm:text-base">Iniciar nova venda</p>
          </button>
          
          <button 
            onClick={() => navigate('/consulta-produtos')}
            disabled={healthError}
            className="bg-green-600 text-white p-6 sm:p-8 rounded-lg hover:bg-green-700 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed shadow-lg"
          >
            <h3 className="text-xl sm:text-2xl font-bold mb-2">Consultar</h3>
            <p className="text-green-100 text-sm sm:text-base">Buscar produtos</p>
          </button>
          
          <button 
            disabled={healthError}
            className="bg-purple-600 text-white p-6 sm:p-8 rounded-lg hover:bg-purple-700 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed shadow-lg"
          >
            <h3 className="text-xl sm:text-2xl font-bold mb-2">Relatórios</h3>
            <p className="text-purple-100 text-sm sm:text-base">Vendas do dia</p>
          </button>
        </div>
      </main>

      {/* Modal Abrir Caixa */}
      <AbrirCaixaModal 
        isOpen={modalAbrirCaixa}
        onClose={() => setModalAbrirCaixa(false)}
      />

      {/* Modal Fechar Caixa */}
      {caixa && (
        <FecharCaixaModal 
          isOpen={modalFecharCaixa}
          onClose={() => setModalFecharCaixa(false)}
          caixa={caixa}
        />
      )}
    </div>
  )
}
