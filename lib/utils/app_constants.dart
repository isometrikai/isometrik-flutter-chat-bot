
const String baseUrl = 'https://service-apis.isometrik.io';
const String chatBaseUrl = 'https://easyagentapi.isometrik.ai';
const String authEndpoint = '/v2/guestAuth';
const String chatEndpoint = '/v1/chatbot';
// Stripe
const String stripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: 'pk_test_51NfUPcHUrndEUSYd4E9FBM0G2CL2WgRejRImsNcGh0IxJ2r5Pcku45FePJyfugKOJCvZFimUTOEDhJyFnEw388Jl00kqLfE93P',
);
