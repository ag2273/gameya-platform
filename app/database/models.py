from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from .db import Base

class Gameya(Base):
    __tablename__ = 'gameyas'
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    total_amount = Column(Float, nullable=False)
    monthly_installment = Column(Float, nullable=False)
    total_months = Column(Integer, nullable=False)

class MemberShare(Base):
    __tablename__ = 'members_shares'
    
    id = Column(Integer, primary_key=True, index=True)
    gameya_id = Column(Integer, ForeignKey('gameyas.id'))
    share_group_id = Column(Integer)
    member_name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    share_ratio = Column(Float, nullable=False)
    payout_month = Column(Integer, nullable=False)

class Installment(Base):
    __tablename__ = 'installments'
    
    id = Column(Integer, primary_key=True, index=True)
    gameya_id = Column(Integer, ForeignKey('gameyas.id'))
    member_id = Column(Integer, ForeignKey('members_shares.id'))
    month_number = Column(Integer, nullable=False)
    status = Column(String, default='pending')
