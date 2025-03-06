import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["result", "status", "progress"]
  
  connect() {
    this.analysisId = this.element.dataset.analysisId
    
    if (this.analysisId) {
      this.subscribeToAnalysisChannel()
    }
  }
  
  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
  
  subscribeToAnalysisChannel() {
    this.subscription = consumer.subscriptions.create(
      { channel: "AnalysisChannel" },
      {
        received: (data) => {
          // Vérifier si le message concerne cette analyse
          if (data.analysis_id == this.analysisId) {
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
  }
} 