from rest_framework import serializers
from .models import Lease, LeaseMember


class LeaseMemberSerializer(serializers.ModelSerializer):
    tenant_name = serializers.CharField(source='tenant.full_name', read_only=True)

    class Meta:
        model = LeaseMember
        fields = ['id', 'tenant', 'tenant_name', 'role']


class LeaseSerializer(serializers.ModelSerializer):
    members = LeaseMemberSerializer(many=True, read_only=True)
    tenant_name = serializers.CharField(source='tenant.full_name', read_only=True)
    room_name = serializers.CharField(source='room.name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Lease
        fields = [
            'id', 'tenant', 'tenant_name', 'room', 'room_name',
            'move_in_date', 'move_out_date', 'rent_amount', 'deposit_amount',
            'status', 'status_display', 'members'
        ]
