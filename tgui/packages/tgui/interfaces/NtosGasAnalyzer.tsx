import { NtosWindow } from '../layouts';
import { GasAnalyzerContent } from './GasAnalyzer';

export const NtosGasAnalyzer = (props) => {
  return (
    <NtosWindow width={500} height={450}>
      <NtosWindow.Content scrollable>
        <GasAnalyzerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
