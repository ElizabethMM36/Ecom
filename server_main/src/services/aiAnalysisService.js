// C:\Users\silvy\Ecom\Ecom\server_main\src\services\aiAnalysisService.js
//
// Communicates with the FastAPI ai_service (Step 9).
// Called every time a user clicks "Submit" on a new listing.
// If FastAPI is down, the listing is still saved with 'Unanalyzed' status
// so your marketplace never breaks because of the AI service.



const axios = require('axios');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8001';

const AI_TIMEOUT_MS = 5000;
const AI_MAX_RETRIES  =  parseInt(process.env.AI_MAX_RETRIES || '2', 10);

/**
 * Sends listing data to the FastAPI AI microservice for risk analysis.
 * Returns a risk cluster result or a safe default if the service is down.
 */
const CONDITION_MAP ={
    'Fair': 1,
 'Used':2,
'Like Now':3,
'New':4,};
// ── Safe default returned when FastAPI is unreachable ────────────────────────
const FALLBACK_RESULT = {
  success:    false,
  clusterId:  null,
  riskLabel:  'Unanalyzed',
  riskAction: 'allow',
  aiRiskScore: null,
  riskCluster: null,
  isFlagged:   false,
  aiAnalyzedAt: null,
  aiRawResponse: null,
  confidence:  'service unavailable — listing saved, analysis pending',
};
 
 
// ── Internal: single axios call ───────────────────────────────────────────────
async function _callFastAPI(payload){
    const response = await axios.post(
        `${AI_SERIVE_URL}/analyze-listing`,
        payload,
        {
            timeout: AI_TIMEOUT_MS,
            headers: {'Content-Type': 'application/json'},
        }
    );
    return response.data ;
}
function _mapToProductFields(data){
    const isFlagged = data.action === 'flag' || data.cluster_id === 2 ;
    const status = isFlagged ? 'under_review': 'available';
    return {
       sucess : true,
       clusterId: data.cluster_id,
        riskCluster:  data.cluster_id,
    riskLabel:    data.risk_label,
    riskAction:   data.action,
    aiRiskScore:  data.cluster_id === 0 ? 0.1
                : data.cluster_id === 1 ? 0.5
                : 0.9,                          // rough score from cluster
    isFlagged,
    status,
    aiAnalyzedAt:  new Date(),
    aiRawResponse: data,
    confidence:    data.confidence_note || '',
    };
}
 
// ── Public: analyzeListingRisk ────────────────────────────────────────────────
// Called from productRoutes.js on every POST /api/products
//
// @param {Object} params
//   price           {number}  - listing price
//   condition       {string}  - 'New' | 'Like New' | 'Used' | 'Fair'
//   sellerRating    {number}  - seller's trustScore (0–5)
//   daysActive      {number}  - days since seller account was created
//
// @returns {Object} - fields ready to spread onto the Product document
async function analyzeListingRisk ({price , condition , sellerRating, daysActive}){
    const conditionValue = CONDITION_MAP[condition] ?? 2 ;
    const payload = {
        price: Number(price),
        reported_condition: conditionValue,
        seller_rating: Number(sellerRating ?? 0),
        days_active: Number(daysActive ?? 0),
    };
    let lastError ;
    for(let attempt = 1 ; attempt <= AI_MAX_RETRIES ; attempt++){

    try{
        const data = await _callFastAPI(payload);
        const result = _mapToProductFields(data);
        console.log(
        `[AI] analyzeListingRisk OK (attempt ${attempt}) →`,
        `cluster=${result.clusterId} label=${result.riskLabel} flagged=${result.isFlagged}`
      );
      return result;
        

    }catch(err){
     lastError = err ;
     const isLastAttempt = attempt === AI_MAX_RETRIES ;
     if (!isLastAttempt){
        console.warn(`[AI] Attempt ${attempt} failed, retrying... (${err.message})`);
        await new Promise(r => setTimeout(r, 500 * attempt)); // back-off
     }

    }}
} 
  // All retries exhausted → graceful degradation
  console.error(`[AI] analyzeListingRisk failed after ${AI_MAX_RETRIES} attempts:`, lastError?.message);
  return { ...FALLBACK_RESULT };
// ── Public: healthCheck ───────────────────────────────────────────────────────
// Useful for your /api/admin/ai-status endpoint or startup check
async function healthCheck() {
  try {
    const response = await axios.get(`${AI_SERVICE_URL}/health`, {
      timeout: 2000,
    });
    return { online: true, data: response.data };
  } catch {
    return { online: false };
  }
}
 
module.exports = { analyzeListingRisk, healthCheck };