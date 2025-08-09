import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/storage_service.dart';

class SidebarMenu extends StatefulWidget {
  final VoidCallback onClose;

  const SidebarMenu({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  int _selectedTab = 0; // 0: History, 1: Storage
  List<Map<String, dynamic>> _historyItems = [];
  List<Map<String, dynamic>> _savedTexts = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final history = await StorageService.getHistory();
      final savedTexts = await StorageService.getSavedTexts();
      final stats = await StorageService.getStats();
      
      setState(() {
        _historyItems = history;
        _savedTexts = savedTexts;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('📱 SidebarMenu: Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchData() async {
    if (_searchQuery.isEmpty) {
      _loadData();
      return;
    }

    try {
      final searchResults = _selectedTab == 0
          ? await StorageService.searchHistory(_searchQuery)
          : await StorageService.searchSavedTexts(_searchQuery);
      
      setState(() {
        if (_selectedTab == 0) {
          _historyItems = searchResults;
        } else {
          _savedTexts = searchResults;
        }
      });
    } catch (e) {
      print('📱 SidebarMenu: Error searching: $e');
    }
  }

  Future<void> _deleteItem(String id, bool isHistory) async {
    try {
      if (isHistory) {
        await StorageService.deleteHistoryItem(id);
      } else {
        await StorageService.deleteSavedText(id);
      }
      
      _loadData(); // Refresh data
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item deleted successfully'),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('📱 SidebarMenu: Error deleting item: $e');
    }
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
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('📱 SidebarMenu: Error copying text: $e');
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _buildStatCard('Total', _stats['totalTranslations'] ?? 0),
              SizedBox(width: 12),
              _buildStatCard('Today', _stats['todayTranslations'] ?? 0),
              SizedBox(width: 12),
              _buildStatCard('Saved', _stats['savedTexts'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Expanded(
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 60,
        borderRadius: 12,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('History', 0, Icons.history),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildTabButton('Storage', 1, Icons.bookmark),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _searchQuery = '';
        });
        _loadData();
      },
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 50,
        borderRadius: 12,
        blur: 10,
        alignment: Alignment.center,
        border: isSelected ? 2 : 1,
        linearGradient: LinearGradient(
          colors: isSelected
              ? [
                  Color(0xFF6C63FF).withOpacity(0.3),
                  Color(0xFF5A52FF).withOpacity(0.2),
                ]
              : [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
        ),
        borderGradient: LinearGradient(
          colors: isSelected
              ? [
                  Color(0xFF6C63FF).withOpacity(0.6),
                  Color(0xFF5A52FF).withOpacity(0.3),
                ]
              : [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 50,
        borderRadius: 12,
        blur: 10,
        alignment: Alignment.centerLeft,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: TextField(
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _searchData();
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search ${_selectedTab == 0 ? 'history' : 'saved texts'}...',
              hintStyle: TextStyle(color: Colors.white60),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white60),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      );
    }

    final items = _selectedTab == 0 ? _historyItems : _savedTexts;
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == 0 ? Icons.history : Icons.bookmark_border,
              size: 64,
              color: Colors.white30,
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results found'
                  : 'No ${_selectedTab == 0 ? 'history' : 'saved texts'} yet',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListItem(item, _selectedTab == 0);
      },
    );
  }

  Widget _buildListItem(Map<String, dynamic> item, bool isHistory) {
    final timestamp = DateTime.parse(item['timestamp']);
    final timeAgo = _getTimeAgo(timestamp);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 200,
        borderRadius: 12,
        blur: 10,
        alignment: Alignment.topLeft,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHistory 
                              ? '${item['sourceLanguage']} → ${item['targetLanguage']}'
                              : item['title'] ?? 'Saved Text',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _copyText(
                          isHistory 
                              ? '${item['originalText']}\n\n${item['translatedText']}'
                              : item['text']
                        ),
                        icon: Icon(Icons.copy, color: Colors.white70, size: 20),
                      ),
                      IconButton(
                        onPressed: () => _deleteItem(item['id'], isHistory),
                        icon: Icon(Icons.delete, color: Colors.red[300], size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Content
              if (isHistory) ...[
                // Original text
                Text(
                  'Original:',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item['originalText'] ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                // Translated text
                Text(
                  'Translated:',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item['translatedText'] ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                // Saved text
                Text(
                  item['text'] ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  '${item['type']?.toString().capitalize()} • ${item['sourceLanguage']}',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: double.infinity,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 0,
        blur: 20,
        alignment: Alignment.topLeft,
        border: 0,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a2e).withOpacity(0.95),
            Color(0xFF16213e).withOpacity(0.9),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            SizedBox(height: 20),
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
