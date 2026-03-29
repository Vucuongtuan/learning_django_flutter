from django.apps import AppConfig

class AiSearchConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.ai_search'

    def ready(self):
        import apps.ai_search.signals
