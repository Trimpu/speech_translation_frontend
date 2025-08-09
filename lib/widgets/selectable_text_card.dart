import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/storage_service.dart';

class SelectableTextCard extends StatefulWidget {
  final String text;
  final String title;
  final String type; // 'original' or 'translated'
  final String sourceLanguage;
  final String targetLanguage;
  final IconData icon;
  final Color accentColor;

  const SelectableTextCard({
    Key? key,
    required this.text,
    required this.title,
    required this.type,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.icon,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<SelectableTextCard> createState() => _SelectableTextCardState();
}

class _SelectableTextCardState extends State<SelectableTextCard> {
  final TextEditingController _controller = TextEditingController();
  bool _hasSelection = false;
  String _selectedText = '';

  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;
    _controller.addListener(_onTextSelectionChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextSelectionChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextSelectionChanged() {
    final selection = _controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final selectedText = _controller.text.substring(
        selection.start,
        selection.end,
      );
      setState(() {
        _hasSelection = true;
        _selectedText = selectedText;
      });
    } else {
      setState(() {
        _hasSelection = false;
        _selectedText = '';
      });
    }
  }

  Future<void> _copySelectedText() async {
    if (_selectedText.isNotEmpty) {
      await _copyText(_selectedText);
    }
  }

  Future<void> _copyAllText() async {
    await _copyText(widget.text);
  }

  Future<void> _copyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Text copied to clipboard'),
            ],
          ),
          backgroundColor: Colors.green.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('📱 SelectableTextCard: Error copying text: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy text'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveText() async {
    try {
      await StorageService.saveText(
        text: widget.text,
        type: widget.type,
        sourceLanguage: widget.sourceLanguage,
        targetLanguage: widget.targetLanguage,
        title: '${widget.title} - ${DateTime.now().toString().split(' ')[0]}',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.bookmark, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Text saved to storage'),
            ],
          ),
          backgroundColor: widget.accentColor.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('📱 SelectableTextCard: Error saving text: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save text'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e).withOpacity(0.95),
              Color(0xFF16213e).withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            
            // Title
            Text(
              '${widget.title} Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            // Action buttons
            _buildActionButton(
              icon: Icons.copy,
              title: 'Copy All Text',
              subtitle: 'Copy entire ${widget.type} text',
              onTap: () {
                Navigator.pop(context);
                _copyAllText();
              },
            ),
            
            if (_hasSelection)
              _buildActionButton(
                icon: Icons.content_copy,
                title: 'Copy Selected',
                subtitle: 'Copy selected portion',
                onTap: () {
                  Navigator.pop(context);
                  _copySelectedText();
                },
              ),
            
            _buildActionButton(
              icon: Icons.bookmark,
              title: 'Save Text',
              subtitle: 'Save to storage for later',
              onTap: () {
                Navigator.pop(context);
                _saveText();
              },
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: widget.accentColor, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 280,
      borderRadius: 16,
      blur: 20,
      alignment: Alignment.topLeft,
      border: 1.5,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.accentColor.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.accentColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Quick action buttons
                Row(
                  children: [
                    if (_hasSelection)
                      IconButton(
                        onPressed: _copySelectedText,
                        icon: Icon(Icons.content_copy, color: Colors.white70, size: 20),
                        tooltip: 'Copy selected',
                      ),
                    IconButton(
                      onPressed: _copyAllText,
                      icon: Icon(Icons.copy, color: Colors.white70, size: 20),
                      tooltip: 'Copy all',
                    ),
                    IconButton(
                      onPressed: _saveText,
                      icon: Icon(Icons.bookmark_border, color: Colors.white70, size: 20),
                      tooltip: 'Save text',
                    ),
                    IconButton(
                      onPressed: _showActionMenu,
                      icon: Icon(Icons.more_vert, color: Colors.white70, size: 20),
                      tooltip: 'More actions',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Text content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: widget.text.isEmpty
                    ? Center(
                        child: Text(
                          'No ${widget.type} text yet',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
              ),
            ),
            
            // Selection indicator
            if (_hasSelection)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_selectedText.length} characters selected',
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
