import consumer from "./consumer"

consumer.subscriptions.create("AnalysisChannel", {
  connected() {
    console.log("Connected to AnalysisChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log("Received data:", data);
    
    // Si nous sommes sur la page d'une analyse spécifique
    const analysisIdMatch = window.location.pathname.match(/\/analyses\/(\d+)/);
    if (analysisIdMatch && data.analysis_id == analysisIdMatch[1]) {
      // Mettre à jour l'interface utilisateur
      this.updateAnalysisUI(data);
    }
    
    // Si nous sommes sur la page d'index des analyses
    if (window.location.pathname === "/analyses" && data.status) {
      // Rafraîchir la page pour voir les mises à jour
      location.reload();
    }
  },
  
  updateAnalysisUI(data) {
    // Cette fonction est appelée par le code spécifique à chaque page
    // Voir le JavaScript dans la vue show.html.erb
  }
}); 