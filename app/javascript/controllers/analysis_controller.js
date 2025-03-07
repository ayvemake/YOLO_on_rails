import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["result", "status", "progress"]
  
  connect() {
    this.analysisId = this.element.dataset.analysisId
    
    if (this.analysisId) {
      console.log(`Analysis controller connected for analysis #${this.analysisId}`)
      this.subscribeToAnalysisChannel()
    }
  }
  
  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
  
  subscribeToAnalysisChannel() {
    console.log(`Subscribing to AnalysisChannel for analysis #${this.analysisId}`)
    this.subscription = consumer.subscriptions.create(
      { channel: "AnalysisChannel" },
      {
        connected: () => {
          console.log(`Connected to AnalysisChannel for analysis #${this.analysisId}`)
        },
        disconnected: () => {
          console.log(`Disconnected from AnalysisChannel for analysis #${this.analysisId}`)
        },
        received: (data) => {
          console.log(`Received data from AnalysisChannel:`, data)
          // Vérifier si le message concerne cette analyse
          if (data.analysis_id == this.analysisId) {
            console.log(`Processing update for analysis #${this.analysisId}`)
            this.handleAnalysisUpdate(data)
          }
        }
      }
    )
  }
  
  handleAnalysisUpdate(data) {
    // Mettre à jour le statut
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = data.status
      
      // Mettre à jour la classe en fonction du statut
      if (data.status === 'completed') {
        this.statusTarget.classList.remove('text-blue-600', 'text-red-600')
        this.statusTarget.classList.add('text-green-600')
      } else if (data.status === 'failed') {
        this.statusTarget.classList.remove('text-blue-600', 'text-green-600')
        this.statusTarget.classList.add('text-red-600')
      }
    }
    
    // Mettre à jour la barre de progression
    if (this.hasProgressTarget) {
      if (data.status === 'completed') {
        this.progressTarget.style.width = '100%'
        this.progressTarget.classList.remove('bg-blue-500')
        this.progressTarget.classList.add('bg-green-500')
      } else if (data.status === 'failed') {
        this.progressTarget.classList.remove('bg-blue-500')
        this.progressTarget.classList.add('bg-red-500')
      }
    }
    
    // Mettre à jour le contenu du résultat
    if (this.hasResultTarget && data.html) {
      this.resultTarget.innerHTML = data.html
    }
    
    // Si l'analyse est terminée et qu'il y a une image résultante, mettre à jour l'image
    if (data.status === 'completed' && data.has_result_image && data.result_image_url) {
      // Trouver ou créer un conteneur pour l'image
      let imageContainer = document.getElementById(`analysis-image-${this.analysisId}`)
      if (!imageContainer) {
        imageContainer = document.createElement('div')
        imageContainer.id = `analysis-image-${this.analysisId}`
        imageContainer.className = 'mt-4'
        this.element.appendChild(imageContainer)
      }
      
      // Mettre à jour l'image
      imageContainer.innerHTML = `
        <h4 class="text-md font-semibold mb-2">Image résultante</h4>
        <img src="${data.result_image_url}" class="max-w-full h-auto rounded-lg shadow-md" alt="Résultat de l'analyse">
      `
    }
    
    // Mettre à jour le message
    if (data.message) {
      // Trouver ou créer un conteneur pour le message
      let messageContainer = document.getElementById(`analysis-message-${this.analysisId}`)
      if (!messageContainer) {
        messageContainer = document.createElement('div')
        messageContainer.id = `analysis-message-${this.analysisId}`
        messageContainer.className = 'mt-4 p-4 rounded-lg'
        this.element.appendChild(messageContainer)
      }
      
      // Définir la classe en fonction du statut
      let bgClass = 'bg-blue-50 text-blue-700'
      if (data.status === 'completed') {
        bgClass = 'bg-green-50 text-green-700'
      } else if (data.status === 'failed') {
        bgClass = 'bg-red-50 text-red-700'
      }
      
      // Mettre à jour le message
      messageContainer.className = `mt-4 p-4 rounded-lg ${bgClass}`
      messageContainer.innerHTML = `<p>${data.message}</p>`
    }
    
    // Mettre à jour également les éléments existants dans la page
    const statusElement = document.getElementById('analysis-status');
    if (statusElement && data.status) {
      statusElement.textContent = data.status;
      
      // Mettre à jour la classe de couleur
      statusElement.className = 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full';
      if (data.status === 'completed') {
        statusElement.classList.add('bg-green-100', 'text-green-800');
      } else if (data.status === 'processing') {
        statusElement.classList.add('bg-blue-100', 'text-blue-800');
      } else if (data.status === 'failed') {
        statusElement.classList.add('bg-red-100', 'text-red-800');
      } else {
        statusElement.classList.add('bg-gray-100', 'text-gray-800');
      }
    }
    
    // Mettre à jour le score
    const scoreElement = document.getElementById('analysis-score');
    if (scoreElement && data.score !== undefined) {
      const scorePercentage = (data.score * 100).toFixed(1) + '%';
      scoreElement.textContent = scorePercentage;
      
      // Mettre à jour la couleur
      if (data.score >= 0.85) {
        scoreElement.classList.remove('text-red-600');
        scoreElement.classList.add('text-green-600');
      } else {
        scoreElement.classList.remove('text-green-600');
        scoreElement.classList.add('text-red-600');
      }
    }
    
    // Mettre à jour l'image dans la section "Image analysée"
    if (data.status === 'completed' && data.has_result_image && data.result_image_url) {
      const imageSection = document.querySelector('.bg-white.shadow .border-t.border-gray-200.p-4');
      if (imageSection) {
        // Remplacer l'image existante par l'image résultante
        imageSection.innerHTML = `
          <div class="relative">
            <img src="${data.result_image_url}" class="w-full h-auto rounded-lg" alt="Résultat de l'analyse">
          </div>
        `;
      }
    }
    
    // Mettre à jour le tableau des résultats
    if (data.status === 'completed' && data.html) {
      const resultsTable = document.getElementById('results-table');
      if (resultsTable) {
        // Recharger la page après un court délai pour afficher les résultats complets
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      }
    }
  }
  
  refreshStatus(event) {
    event.preventDefault()
    
    console.log(`Refreshing status for analysis #${this.analysisId}`)
    
    fetch(`/analyses/${this.analysisId}/status`)
      .then(response => response.json())
      .then(data => {
        console.log(`Received status update:`, data)
        this.handleAnalysisUpdate({
          analysis_id: data.id,
          status: data.status,
          score: data.score,
          has_result_image: data.has_result_image,
          result_image_url: data.result_image_url,
          message: `Statut mis à jour: ${data.status}`
        })
        
        // Si l'analyse est terminée et qu'il y a des résultats, recharger la page
        if (data.status === 'completed' && data.results_count > 0) {
          setTimeout(() => {
            window.location.reload()
          }, 1000)
        }
      })
      .catch(error => {
        console.error(`Error refreshing status:`, error)
      })
  }
} 