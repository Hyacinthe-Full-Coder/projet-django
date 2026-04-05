import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  Color get _statColor {
    switch (ticket.status) {
      case 'OUVERT':
        return Colors.blue.shade700;
      case 'EN_COURS':
        return Colors.orange.shade700;
      case 'RESOLU':
        return Colors.green.shade700;
      case 'CLOS':
        return Colors.red.shade600;
      default:
        return Colors.black;
    }
  }

  Color get _priorColor {
    switch (ticket.priorite) {
      case 'BASSE':
        return Colors.green.shade700;
      case 'NORMALE':
        return Colors.blue.shade700;
      case 'HAUTE':
        return Colors.orange.shade700;
      case 'CRITIQUE':
        return Colors.red.shade700;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.titre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statColor.withValues(alpha: 0.12),
                      border: Border.all(color: _statColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.status,
                      style: TextStyle(
                        color: _statColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.flag, size: 14, color: _priorColor),
                  const SizedBox(width: 4),
                  Text(
                    ticket.priorite,
                    style: TextStyle(color: _priorColor, fontSize: 12),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ticket.auteurNom,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
