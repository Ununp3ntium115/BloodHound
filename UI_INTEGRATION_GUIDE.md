# 🔥 UI Integration Guide - PYRO Detector

**Integrating PYRO Detector into the BloodHound UI**

---

## ✅ Integration Complete

The PYRO Detector view has been successfully integrated into the BloodHound UI as a Zenmap-like network visualization interface.

---

## 📦 What Was Added

### 1. Route Definition
**File**: `cmd/ui/src/routes/constants.ts`
- Added `ROUTE_PYRO_DETECTOR = '/pyro-detector'`

### 2. Route Registration
**File**: `cmd/ui/src/routes/index.ts`
- Added lazy-loaded `PyroDetector` component
- Registered route with authentication required
- Added to navigation menu

### 3. Navigation Menu
**File**: `cmd/ui/src/components/MainNav/MainNavData.tsx`
- Added "PYRO Detector" to primary navigation list
- Uses `AppIcon.Radar` icon (may need adjustment)
- Accessible from main navigation bar

### 4. View Component
**Files**: 
- `cmd/ui/src/views/PyroDetector/PyroDetectorView.tsx` - Main component
- `cmd/ui/src/views/PyroDetector/index.ts` - Export

**Features**:
- Network graph visualization (Sigma.js)
- Detonator list and execution
- Investigation controls
- Status display
- Responsive layout

---

## 🎯 Component Features

### Network Visualization
- ✅ Interactive graph using Sigma.js
- ✅ Node and edge rendering
- ✅ Zoom and pan controls
- ✅ Click interactions
- ✅ Context menu support (placeholder)

### Fire Marshal Integration
- ✅ Detonator list UI
- ✅ Execute detonator interface
- ✅ Case management controls
- ✅ Agent list controls
- ✅ PQL query interface

### UI Components
- ✅ Material-UI integration
- ✅ Dark mode support
- ✅ Responsive layout
- ✅ Loading states
- ✅ Status indicators

---

## 🔄 Next Steps (TODO)

### API Integration
1. **Create API Client**
   - Create `cmd/ui/src/api/pyroDetector.ts`
   - Implement methods for MCP server communication
   - Handle authentication

2. **Update Queries**
   - Replace placeholder `useQuery` calls
   - Connect to actual PYRO Detector MCP server
   - Handle real API responses

3. **Data Transformation**
   - Transform API responses to graph data
   - Map detonator results to nodes/edges
   - Handle different result types

### Enhanced Features
1. **Node/Edge Details**
   - Add detail panels
   - Show properties
   - Display metadata

2. **Filtering & Search**
   - Filter nodes by type
   - Search functionality
   - Graph filtering

3. **Export**
   - Export graph as image
   - Export data as JSON
   - Export as report

4. **Real-time Updates**
   - WebSocket connection
   - Live status updates
   - Progress indicators

### Testing
1. **Unit Tests**
   - Component tests
   - Hook tests
   - Utility tests

2. **Integration Tests**
   - API integration
   - Graph rendering
   - User interactions

---

## 🔌 API Integration Example

### Step 1: Create API Client

```typescript
// cmd/ui/src/api/pyroDetector.ts
import { useQuery, useMutation } from '@tanstack/react-query';

const PYRO_DETECTOR_API_BASE = '/api/pyro-detector';

export const usePyroDetectors = () => {
  return useQuery({
    queryKey: ['pyro-detectors'],
    queryFn: async () => {
      const response = await fetch(`${PYRO_DETECTOR_API_BASE}/list-detonators`);
      if (!response.ok) throw new Error('Failed to fetch detonators');
      return response.json();
    },
  });
};

export const useExecuteDetonator = () => {
  return useMutation({
    mutationFn: async (detonatorId: string) => {
      const response = await fetch(`${PYRO_DETECTOR_API_BASE}/execute`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ detonator_id: detonatorId }),
      });
      if (!response.ok) throw new Error('Failed to execute detonator');
      return response.json();
    },
  });
};
```

### Step 2: Update Component

```typescript
// In PyroDetectorView.tsx
import { usePyroDetectors, useExecuteDetonator } from 'src/api/pyroDetector';

// Replace placeholder query
const { data: detonators, isLoading: detonatorsLoading } = usePyroDetectors();
```

---

## 📁 File Structure

```
cmd/ui/src/
├── routes/
│   ├── constants.ts          # ✅ Added ROUTE_PYRO_DETECTOR
│   └── index.ts              # ✅ Registered route
├── components/
│   └── MainNav/
│       └── MainNavData.tsx   # ✅ Added navigation item
└── views/
    └── PyroDetector/
        ├── PyroDetectorView.tsx  # ✅ Main component
        ├── index.ts              # ✅ Export
        └── README.md             # ✅ Documentation
```

---

## 🎨 UI Layout

```
┌─────────────────────────────────────────────────┐
│  PYRO Detector - Network Mapping               │
├──────────────┬──────────────────────────────────┤
│              │                                  │
│  Detonators  │    Network Graph Visualization  │
│  List        │                                  │
│              │                                  │
│  - Det 1     │    [Interactive Sigma.js Graph] │
│  - Det 2     │                                  │
│  - Det 3     │                                  │
│              │                                  │
│  Controls    │                                  │
│  - Create    │                                  │
│  - List      │                                  │
│  - Execute   │                                  │
│              │                                  │
│  Status      │                                  │
│  - Active    │                                  │
│  - Nodes: 3  │                                  │
│  - Edges: 2  │                                  │
└──────────────┴──────────────────────────────────┘
```

---

## 🔧 Configuration

### Icon Note
The navigation uses `AppIcon.Radar` - verify this icon exists in `bh-shared-ui`. If not, use an alternative:
- `AppIcon.Network`
- `AppIcon.Radar`
- `AppIcon.Compass` (already used for API Explorer)
- Or create a custom icon

### Route Path
- **Path**: `/ui/pyro-detector`
- **Authentication**: Required
- **Navigation**: Visible in main menu

---

## ✅ Verification Checklist

- ✅ Route defined in constants
- ✅ Route registered in routes
- ✅ Navigation menu item added
- ✅ View component created
- ✅ Graph visualization setup
- ✅ UI layout implemented
- ✅ Placeholder data structure
- ⏳ API integration (TODO)
- ⏳ Real data connection (TODO)
- ⏳ Enhanced features (TODO)

---

## 📚 Related Documentation

- [PYRO Detector MCP Server](../pyro-detector/README_START_HERE.md)
- [PYRO Detector API Reference](../pyro-detector/API_REFERENCE.md)
- [Component README](cmd/ui/src/views/PyroDetector/README.md)

---

## 🎉 Status

**UI Integration**: ✅ **COMPLETE**  
**API Integration**: ⏳ **TODO**  
**Enhanced Features**: ⏳ **TODO**

The PYRO Detector view is now integrated into the BloodHound UI and ready for API connection!

---

🔥 **UI Integration Guide - PYRO Detector** 🔥

*Zenmap-like network visualization interface*

