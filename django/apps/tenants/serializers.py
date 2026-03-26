from rest_framework import serializers
from .models import Tenant, IdentityDocument


class IdentityDocumentSerializer(serializers.ModelSerializer):
    doc_type_display = serializers.CharField(source='get_doc_type_display', read_only=True)

    class Meta:
        model = IdentityDocument
        fields = ['id', 'doc_type', 'doc_type_display', 'front_image_url', 'back_image_url', 'issue_date']


class TenantSerializer(serializers.ModelSerializer):
    documents = IdentityDocumentSerializer(many=True, read_only=True)
    gender_display = serializers.CharField(source='get_gender_display', read_only=True)

    class Meta:
        model = Tenant
        fields = [
            'id', 'full_name', 'phone', 'email', 'date_of_birth',
            'gender', 'gender_display', 'identity_number', 'documents'
        ]
